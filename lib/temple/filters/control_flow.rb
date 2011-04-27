module Temple
  module Filters
    class ControlFlow < Filter
      def on_if(condition, yes, no = nil)
        result = [:multi, [:code, "if #{condition}"], compile(yes)]
        while no && no.first == :if
          result << [:code, "elsif #{no[1]}"] << compile(no[2])
          no = no[3]
        end
        result << [:code, 'else'] << compile(no) if no
        result << [:code, 'end']
        result
      end

      def on_block(code, exp)
        [:multi,
         [:code, code],
         compile(exp),
         [:code, 'end']]
      end
    end
  end
end
