module Temple
  module Mixins
    module Dispatcher
      def compile(exp)
        type, *args = exp
        if respond_to?("on_#{type}")
          send("on_#{type}", *args)
        else
          exp
        end
      end

      def on_multi(*exps)
        [:multi, *exps.map {|exp| compile(exp) }]
      end

      def on_capture(name, exp)
        [:capture, name, compile(exp)]
      end
    end

    module Options
      def self.included(base)
        base.class_eval do
          def self.default_options
            @default_options ||= superclass.respond_to?(:default_options) ? superclass.default_options.dup : {}
          end
        end
      end

      def initialize(options = {})
        @options = self.class.default_options.merge(options)
      end
    end
  end
end

