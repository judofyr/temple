$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'test/unit'
require 'temple'

def TestFilter(klass)
  klass = Temple::Filters.const_get(klass.to_s) unless klass.is_a?(Class)

  Class.new(Test::Unit::TestCase) do
    define_method(:setup) do
      @filter = klass.new
    end

    # Dummy test so Turn doesn't complain
    def test_void
    end

    def self.name
      super || "<anonymous>"
    end
  end
end
