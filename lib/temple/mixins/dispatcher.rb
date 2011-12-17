module Temple
  module Mixins
    # @api private
    module CoreDispatcher
      def on_multi(*exps)
        multi = [:multi]
        exps.each {|exp| multi << compile(exp) }
        multi
      end

      def on_capture(name, exp)
        [:capture, name, compile(exp)]
      end
    end

    # @api private
    module EscapeDispatcher
      def on_escape(flag, exp)
        [:escape, flag, compile(exp)]
      end
    end

    # @api private
    module ControlFlowDispatcher
      def on_if(condition, *cases)
        [:if, condition, *cases.compact.map {|e| compile(e) }]
      end

      def on_case(arg, *cases)
        [:case, arg, *cases.map {|condition, exp| [condition, compile(exp)] }]
      end

      def on_block(code, content)
        [:block, code, compile(content)]
      end

      def on_cond(*cases)
        [:cond, *cases.map {|condition, exp| [condition, compile(exp)] }]
      end
    end

    # @api private
    module CompiledDispatcher
      def call(exp)
        compile(exp)
      end

      def compile(exp)
        dispatcher(exp)
      end

      private

      def case_statement(types, level, on_unknown = nil)
        code = "case exp[#{level}]\n"
        types.each do |name, method|
          code << "when #{name.to_sym.inspect}\n" <<
            (Hash === method ? case_statement(method, level + 1, on_unknown) : "#{method}(*(exp[#{level+1}..-1]))\n")
        end
        if on_unknown
          code << "else\n#{on_unknown}(*exp)\nend\n"
        else
          code << "else\nexp\nend\n"
        end
      end

      def dispatcher(exp)
        replace_dispatcher(exp)
      end

      def replace_dispatcher(exp)
        types = {}
        self.class.instance_methods.each do |method|
          next if method.to_s !~ /^on_(.*)$/
          method_types = $1.split('_')
          (0...method_types.size).inject(types) do |tmp, i|
            unless Hash === tmp
              conflict = method_types[0...i].join('_')
              raise "Temple dispatcher '#{method}' conflicts with 'on_#{conflict}'"
            end
            if i == method_types.size - 1
              tmp[method_types[i]] = method
            else
              tmp[method_types[i]] ||= {}
            end
          end
        end
        on_unknown = self.respond_to?(:on_unknown) ? 'on_unknown' : nil
        self.class.class_eval %{
          def dispatcher(exp)
            if self.class == #{self.class}
              #{case_statement(types, 0, on_unknown)}
            else
              replace_dispatcher(exp)
            end
          end
        }
        dispatcher(exp)
      end
    end

    # @api private
    module Dispatcher
      include CompiledDispatcher
      include CoreDispatcher
      include EscapeDispatcher
      include ControlFlowDispatcher
    end
  end
end
