task :default => :spec
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new {|t| t.spec_opts = ['--color']}


begin
  project = 'temple'
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = project
    gem.summary = "Template compilation framework in Ruby"
    gem.email = "judofyr@gmail.com"
    gem.homepage = "http://github.com/judofyr/#{project}"
    gem.authors = ["Magnus Holm"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end