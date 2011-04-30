module Temple
  module Mixins
    module CoreDispatcher
      def on_multi(*exps)
        [:multi, *exps.map {|exp| compile(exp) }]
      end

      def on_capture(name, exp)
        [:capture, name, compile(exp)]
      end
    end

    module EscapeDispatcher
      def on_escape(flag, exp)
        [:escape, flag, compile(exp)]
      end
    end

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

    module Dispatcher
      include CoreDispatcher
      include EscapeDispatcher
      include ControlFlowDispatcher

      def self.included(base)
        base.class_eval { extend ClassMethods }
      end

      def call(exp)
        compile(exp)
      end

      def compile(exp)
        type, *args = exp
        if respond_to?("on_#{type}")
          send("on_#{type}", *args)
        else
          exp
        end
      end

      module ClassMethods
        def dispatch(*bases)
          bases.each do |base|
            class_eval %{def on_#{base}(type, *args)
              if respond_to?("on_" #{base.to_s.inspect} "_\#{type}")
                send("on_" #{base.to_s.inspect} "_\#{type}", *args)
              else
                [:#{base}, type, *args]
              end
            end}
          end
        end
      end
    end
  end
end
