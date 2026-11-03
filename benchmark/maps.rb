#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage: ruby benchmark/maps.rb BASE [HEAD] > results.json
# HEAD defaults to the working tree. Both revisions use this script and Ruby.
# Settings are deliberately shared by all workers; edit them here, not per run.
require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'

PROCESS_PAIRS = 7
SAMPLES = 7
REFERENCE_ITERATIONS = 5_000
MAP_ITERATIONS = 2_000
COMPILE_ITERATIONS = 100
ROOT = File.expand_path('..', __dir__)
TEMPLATE = '<h1><%== "<&>" %></h1><% 3.times do |i| %><p><%= i %></p><% end %>'
EXPECTED = '<h1>&lt;&amp;&gt;</h1><p>0</p><p>1</p><p>2</p>'

def measure
  GC.start
  allocated = GC.stat(:total_allocated_objects)
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  yield
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
  {seconds: elapsed, allocations: GC.stat(:total_allocated_objects) - allocated}
end

def sample(reference, scenario, reverse)
  measurements = {}
  order = [[:reference, reference], [:scenario, scenario]]
  order.reverse! if reverse
  order.each {|name, work| measurements[name] = measure(&work) }
  measurements[:ratio] = measurements[:scenario][:seconds] / measurements[:reference][:seconds]
  measurements
end

def worker(index)
  reference_hash = (0...32).map {|i| [i, i * 2] }.to_h
  reference = proc do
    REFERENCE_ITERATIONS.times do
      sum = 0
      reference_hash.each_key {|key| sum += reference_hash[key] }
      raise 'Unexpected reference result' unless sum == 992
    end
  end
  reference.call

  compiled = nil
  boot = proc do
    require 'temple'
    compiled = Temple::ERB::Engine.new.call(TEMPLATE)
  end
  results = {'load_and_first_compile' => [sample(reference, boot, index.odd?)]}
  raise 'Unexpected compiled output' unless eval(compiled) == EXPECTED

  defaults = (0...32).map {|i| [:"option_#{i}", i] }.to_h
  flat = Temple::ImmutableMap.new(defaults)
  inherited = defaults
  4.times do |depth|
    inherited = Temple::ImmutableMap.new({:"level_#{depth}" => depth, option_0: nil}, inherited)
  end
  raise 'Unexpected map output' unless inherited.to_hash == defaults.merge(
    option_0: nil, level_0: 0, level_1: 1, level_2: 2, level_3: 3)

  scenarios = {
    'flat_map' => proc { MAP_ITERATIONS.times { flat.to_hash } },
    'inherited_map' => proc { MAP_ITERATIONS.times { inherited.to_hash } },
    'compile' => proc { COMPILE_ITERATIONS.times { Temple::ERB::Engine.new.call(TEMPLATE) } }
  }
  scenarios.each do |name, scenario|
    scenario.call
    results[name] = Array.new(SAMPLES) {|pass| sample(reference, scenario, (index + pass).odd?) }
  end
  results
end

def capture(*command)
  stdout, stderr, status = Open3.capture3(*command)
  raise "#{command.join(' ')} failed:\n#{stderr}" unless status.success?
  stdout
end

def export_revision(ref, directory)
  sha = capture('git', '-C', ROOT, 'rev-parse', '--verify', "#{ref}^{commit}").strip
  archive = capture('git', '-C', ROOT, 'archive', sha, 'lib')
  Dir.mkdir(directory)
  _, stderr, status = Open3.capture3('tar', '-xf', '-', '-C', directory, stdin_data: archive)
  raise "Extracting #{sha} failed:\n#{stderr}" unless status.success?
  [sha, File.join(directory, 'lib')]
end

def median(values)
  sorted = values.sort
  middle = sorted.length / 2
  sorted.length.odd? ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2.0
end

if ARGV.first == '--worker'
  puts JSON.generate(worker(Integer(ARGV.fetch(1))))
else
  abort 'Usage: ruby benchmark/maps.rb BASE [HEAD] > results.json' unless (1..2).cover?(ARGV.length)

  Dir.mktmpdir('temple-map-benchmark') do |directory|
    base, base_lib = export_revision(ARGV[0], File.join(directory, 'base'))
    head, head_lib = if ARGV[1]
      export_revision(ARGV[1], File.join(directory, 'head'))
    else
      ['working tree', File.join(ROOT, 'lib')]
    end

    runs = {'base' => [], 'head' => []}
    PROCESS_PAIRS.times do |pair|
      order = [['base', base_lib], ['head', head_lib]]
      order.reverse! if pair.odd?
      order.each do |name, lib|
        warn "Pair #{pair + 1}/#{PROCESS_PAIRS}: #{name}"
        output = capture(RbConfig.ruby, '-I', lib, __FILE__, '--worker', pair.to_s)
        runs[name] << JSON.parse(output)
      end
    end

    iterations = {
      'load_and_first_compile' => 1,
      'flat_map' => MAP_ITERATIONS,
      'inherited_map' => MAP_ITERATIONS,
      'compile' => COMPILE_ITERATIONS
    }
    summary = {}
    iterations.each do |name, count|
      summary[name] = {}
      runs.each do |revision, processes|
        samples = processes.flat_map {|process| process.fetch(name) }
        summary[name][revision] = {
          samples: samples.length,
          ratio: median(samples.map {|s| s.fetch('ratio') }),
          microseconds_per_iteration: median(samples.map {|s| s['scenario']['seconds'] }) * 1_000_000 / count,
          allocations_per_iteration: median(samples.map {|s| s['scenario']['allocations'] }) / count.to_f,
          reference_seconds: median(samples.map {|s| s['reference']['seconds'] })
        }
      end
      summary[name][:ratio_change_percent] =
        (summary[name]['head'][:ratio] / summary[name]['base'][:ratio] - 1) * 100
    end

    puts JSON.pretty_generate(
      ruby: RUBY_DESCRIPTION,
      base: base,
      head: head,
      process_pairs: PROCESS_PAIRS,
      samples_per_process: SAMPLES,
      reference_iterations: REFERENCE_ITERATIONS,
      scenario_iterations: iterations,
      summary: summary,
      runs: runs
    )
  end
end
