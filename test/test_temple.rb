require File.dirname(__FILE__) + '/helper'

class TestTempleGenerator < Test::Unit::TestCase
  def spec
    @spec ||= begin
      require 'rubygems'
      require 'rubygems/specification'
      
      Gem::Specification.load(File.dirname(__FILE__) + '/../temple.gemspec')
    end
  end
  
  def test_correct_version
    assert_equal(spec.version.to_s, Temple::VERSION)
  end
  
  def test_files_included(base = Temple)
    return unless base.respond_to?(:constants)
    
    base.constants.each do |const|
      if path = base.autoload?(const)
        assert(spec.files.include?("lib/#{path}.rb"), "gemspec did not include lib/#{path}.rb")
      else
        test_files_included(base.const_get(const))
      end
    end
  end
end