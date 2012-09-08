module Temple
  module Mixins
    # @api public
    module DefaultOptions
      def set_default_options(opts)
        default_options.update(opts)
      end

      def default_options
        @default_options ||= OptionHash.new(superclass.respond_to?(:default_options) ?
                                            superclass.default_options : nil) do |hash, key|
          raise ArgumentError, "Option #{key.inspect} is not supported by #{self}" unless @option_validator_disabled
        end
      end

      def define_options(*opts)
        if opts.last.respond_to?(:keys)
          hash = opts.pop
          default_options.add(hash.keys)
          default_options.update(hash)
        end
        default_options.add(opts)
      end

      def disable_option_validator!
        @option_validator_disabled = true
      end
    end

    # @api public
    module Options
      def self.included(base)
        base.class_eval { extend DefaultOptions }
      end

      attr_reader :options

      def initialize(opts = {})
        self.class.default_options.validate_hash!(opts)
        @options = ImmutableHash.new(opts, self.class.default_options)
      end
    end
  end
end
