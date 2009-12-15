$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'temple'
require 'bacon'

def describe_filter(name, &blk)
  klass = Temple::Filters.const_get(name)
  describe(klass) do
    before do
      @filter = klass.new
    end
    
    instance_eval(&blk)
  end
end
