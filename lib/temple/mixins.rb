module Temple
  module Mixins
    module Dispatcher
      def self.included(base)
        base.class_eval { extend ClassMethods }
      end

      def compile(exp)
        compile!(exp)
      end

      def compile!(exp)
        type, *args = exp
        if respond_to?("on_#{type}")
          send("on_#{type}", *args)
        else
          exp
        end
      end

      def on_multi(*exps)
        [:multi, *exps.map {|exp| compile!(exp) }]
      end

      def on_capture(name, exp)
        [:capture, name, compile!(exp)]
      end

      module ClassMethods
        def temple_dispatch(*bases)
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

    module DefaultOptions
      def set_default_options(options)
        default_options.update(options)
      end

      def default_options
        @default_options ||= if superclass.respond_to?(:default_options)
                               Hash.new {|hash, key| superclass.default_options[key] }
                             else
                               {}
                             end
      end
    end

    module Options
      def self.included(base)
        base.class_eval { extend DefaultOptions }
      end

      attr_reader :options

      def initialize(options = {})
        @options = self.class.default_options.merge(options)
      end
    end
  end
end
