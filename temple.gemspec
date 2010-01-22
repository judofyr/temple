# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{temple}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Magnus Holm"]
  s.date = %q{2010-01-23}
  s.email = %q{judofyr@gmail.com}
  s.files = ["LICENSE", "README.md", "Rakefile", "VERSION", "lib/temple.rb", "lib/temple/core.rb", "lib/temple/engine.rb", "lib/temple/filters/dynamic_inliner.rb", "lib/temple/filters/escapable.rb", "lib/temple/filters/mustache.rb", "lib/temple/filters/static_merger.rb", "lib/temple/generator.rb", "lib/temple/parsers/erb.rb", "lib/temple/parsers/mustache.rb", "spec/dynamic_inliner_spec.rb", "spec/escapable_spec.rb", "spec/spec_helper.rb", "spec/static_merger_spec.rb", "spec/temple/parsers/erb_spec.rb", "spec/temple_spec.rb", "temple.gemspec"]
  s.homepage = %q{http://github.com/judofyr/temple}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
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

Gemify.last_specification.manifest = %q{auto} if defined?(Gemify)
