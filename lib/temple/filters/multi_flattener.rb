# frozen_string_literal: true
module Temple
  module Filters
    # Flattens nested multi expressions
    #
    # @api public
    class MultiFlattener < Filter
      def on_multi(*exps)
        # If the multi contains a single element, just return the element
        return compile(exps.first) if exps.size == 1
        result = [:multi]

        exps.each do |exp|
          exp = compile(exp)
          if exp.first == :multi
            # Avoid allocating an intermediate array with exp[1..-1]
            i = 1
            while i < exp.size
              result << exp[i]
              i += 1
            end
          else
            result << exp
          end
        end

        result
      end
    end
  end
end
