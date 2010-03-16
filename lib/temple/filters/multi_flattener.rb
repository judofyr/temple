module Temple
  module Filters
    class MultiFlattener
      def initialize(options = {})
        @options = {}
      end
      
      def compile(exp)
        return exp unless exp.first == :multi
        # If the multi contains a single element, just return the element
        return compile(exp[1]) if exp.length == 2
        result = [:multi]
        
        exp[1..-1].each do |e|
          e = compile(e)
          if e.first == :multi
            result.concat(e[1..-1])
          else
            result << e
          end
        end
        
        result
      end
    end
  end
end