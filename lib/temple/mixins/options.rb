module Temple
  module Mixins
    # @api public
    module DefaultOptions
      def set_default_options(opts)
        default_options.update(opts)
      end

      def default_options
        @default_options ||= OptionHash.new(superclass.respond_to?(:default_options) ?
                                            superclass.default_options : nil) do |hash, key, deprecated|
          unless @option_validator_disabled
            if deprecated
              puts "Option #{key.inspect} is deprecated by #{self}"
            else
              raise ArgumentError, "Option #{key.inspect} is not supported by #{self}"
            end
          end
        end
      end

      def define_options(*opts)
        if opts.last.respond_to?(:keys)
          hash = opts.pop
          default_options.add_valid_keys(hash.keys)
          default_options.update(hash)
        end
        default_options.add_valid_keys(opts)
      end

      def deprecated_options(*opts)
        if opts.last.respond_to?(:keys)
          hash = opts.pop
          default_options.add_deprecated_keys(hash.keys)
          default_options.update(hash)
        end
        default_options.add_deprecated_keys(opts)
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
        raise ArgumentError, "Options must be given as hash" unless opts.keys
        self.class.default_options.validate_hash!(opts)
        @options = ImmutableHash.new(opts, self.class.default_options)
      end
    end
  end
end
