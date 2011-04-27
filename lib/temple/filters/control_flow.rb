module Temple
  module Filters
    class ControlFlow < Filter
      def on_if(condition, yes, no = nil)
        result = [:multi, [:block, "if #{condition}"], compile(yes)]
        while no && no.first == :if
          result << [:block, "elsif #{no[1]}"] << compile(no[2])
          no = no[3]
        end
        result << [:block, 'else'] << compile(no) if no
        result << [:block, 'end']
        result
      end

      def on_loop(code, exp)
        [:multi,
         [:block, code],
         compile(exp),
         [:block, 'end']]
      end
    end
  end
end
