module Temple
  module Filters
    # Merges several statics into a single static.  Example:
    #
    #   [:multi,
    #     [:static, "Hello "],
    #     [:static, "World!"]]
    #
    # Compiles to:
    # 
    #   [:multi,
    #     [:static, "Hello World!"]]
    class StaticMerger
      def compile(exp)
        exp.first == :multi ? on_multi(*exp[1..-1]) : exp
      end

      def on_multi(*exps)
        res = [:multi]
        curr = nil
        state = :looking
        
        exps.each do |exp|
          if exp.first == :static
            if state == :looking
              res << [:static, (curr = exp[1].dup)]
              state = :static
            else
              curr << exp[1]
            end
          else
            res << compile(exp)
            state = :looking unless exp.first == :newline
          end
        end
        
        res
      end
    end
  end
end