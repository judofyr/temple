# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{temple}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Magnus Holm"]
  s.date = %q{2010-01-23}
  s.email = %q{judofyr@gmail.com}
  s.files = [".yardopts", "LICENSE", "README.md", "Rakefile", "lib/temple.rb", "lib/temple/core.rb", "lib/temple/engine.rb", "lib/temple/engines/erb.rb", "lib/temple/filters/dynamic_inliner.rb", "lib/temple/filters/multi_flattener.rb", "lib/temple/filters/static_merger.rb", "lib/temple/generator.rb", "lib/temple/html/fast.rb", "lib/temple/parsers/erb.rb", "lib/temple/utils.rb", "temple.gemspec", "test/engines/hello.erb", "test/engines/test_erb.rb", "test/engines/test_erb_m17n.rb", "test/filters/test_dynamic_inliner.rb", "test/filters/test_static_merger.rb", "test/helper.rb", "test/test_generator.rb", "test/test_temple.rb"]
  s.homepage = %q{http://dojo.rubyforge.org/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Template compilation framework in RUby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
