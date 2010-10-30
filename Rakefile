require 'rake/testtask'

def command?(command)
  system("type #{command} > /dev/null")
end

task :default => :test

if RUBY_VERSION[0,3] == "1.8" and command?("turn")
  task :test do
    suffix = "-n #{ENV['TEST']}" if ENV['TEST']
    sh "turn test/test_*.rb test/**/test_*.rb #{suffix}"
  end
else
  Rake::TestTask.new do |t|
    t.libs << 'lib' << 'test'
    t.pattern = 'test/**/test_*.rb'
    t.verbose = false
  end
end
