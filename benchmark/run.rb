#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Temple compilation benchmark suite.
#
# Measures the time to compile ERB templates through Temple's pipeline:
#   Parser → Filters → Generator
#
# Usage:
#   ruby benchmark/run.rb              # Full benchmark
#   ruby benchmark/run.rb --profile    # Profile hotspots with stackprof
#

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'benchmark/ips'
require 'temple'
require_relative 'templates'

# ---------- Setup ----------

engine = Temple::ERB::Engine.new

puts "Temple #{Temple::VERSION} on Ruby #{RUBY_VERSION}"
puts "=" * 60
puts

# ---------- Template sizes ----------

puts "Template sizes:"
BenchmarkTemplates::ALL.each do |name, src|
  lines = src.count("\n")
  bytes = src.bytesize
  puts "  %-20s %4d lines, %5d bytes" % [name, lines, bytes]
end
puts

# ---------- Verify compilation works ----------

BenchmarkTemplates::ALL.each do |name, src|
  begin
    engine.call(src)
  rescue => e
    abort "ERROR: #{name} failed to compile: #{e.message}"
  end
end
puts "All templates compile successfully."
puts

# ---------- Phase breakdown ----------

puts "Phase breakdown (single run, microseconds):"
puts "-" * 60

parser    = Temple::ERB::Parser.new
trimming  = Temple::ERB::Trimming.new
escapable = Temple::Filters::Escapable.new(use_html_safe: false)
splitter  = Temple::Filters::StringSplitter.new
analyzer  = Temple::Filters::StaticAnalyzer.new
flattener = Temple::Filters::MultiFlattener.new
merger    = Temple::Filters::StaticMerger.new
generator = Temple::Generators::ArrayBuffer.new

phases = [
  ["Parse",          parser],
  ["Trimming",       trimming],
  ["Escapable",      escapable],
  ["StringSplitter", splitter],
  ["StaticAnalyzer", analyzer],
  ["MultiFlattener", flattener],
  ["StaticMerger",   merger],
  ["Generator",      generator],
]

BenchmarkTemplates::ALL.each do |name, src|
  puts "\n  #{name}:"
  sexp = src
  phases.each do |phase_name, filter|
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    1000.times { filter.call(sexp) }
    t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    us = ((t1 - t0) / 1000.0) * 1_000_000
    printf "    %-18s %8.1f µs\n", phase_name, us
    sexp = filter.call(sexp)
  end
end
puts

# ---------- IPS benchmark ----------

puts "=" * 60
puts "Iterations per second (higher is better):"
puts "=" * 60
puts

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  BenchmarkTemplates::ALL.each do |name, src|
    x.report("compile: #{name}") { engine.call(src) }
  end

  x.compare!
end

# ---------- Individual filter IPS ----------

puts
puts "=" * 60
puts "Filter-level IPS for largest template (admin_dashboard):"
puts "=" * 60
puts

src = BenchmarkTemplates::ADMIN_DASHBOARD
sexps = {}
sexp = src
phases.each do |phase_name, filter|
  sexps[phase_name] = sexp
  sexp = filter.call(sexp)
end

Benchmark.ips do |x|
  x.config(time: 3, warmup: 1)

  phases.each do |phase_name, filter|
    input = sexps[phase_name]
    x.report(phase_name) { filter.call(input) }
  end

  x.compare!
end

# ---------- Optional stackprof ----------

if ARGV.include?('--profile')
  require 'stackprof'

  puts
  puts "=" * 60
  puts "StackProf profile (compile admin_dashboard 10,000 times):"
  puts "=" * 60

  src = BenchmarkTemplates::ADMIN_DASHBOARD
  profile = StackProf.run(mode: :cpu, interval: 100, raw: true) do
    10_000.times { engine.call(src) }
  end

  StackProf::Report.new(profile).print_text
end
