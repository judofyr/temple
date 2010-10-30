# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{temple}
  s.version = "0.1.3"

  s.authors = ["Magnus Holm"]
  s.date = %q{2010-01-23}
  s.email = %q{judofyr@gmail.com}
  s.homepage = %q{http://dojo.rubyforge.org/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Template compilation framework in Ruby}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
