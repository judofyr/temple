# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + "/lib/temple/version"

Gem::Specification.new do |s|
  s.name = %q{temple}
  s.version = Temple::VERSION

  s.authors = ["Magnus Holm"]
  s.date = %q{2011-01-19}
  s.email = %q{judofyr@gmail.com}
  s.homepage = %q{http://dojo.rubyforge.org/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Template compilation framework in Ruby}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  # Tilt is only development dependency because most parts of Temple
  # can be used without it.
  s.add_development_dependency('tilt')
  s.add_development_dependency('bacon')
end
