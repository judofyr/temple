module Temple
  module Mixins
    # @api public
    module DefaultOptions
      def set_default_options(opts)
        default_options.update(opts)
      end

      def default_options
        @default_options ||= MutableHash.new(superclass.respond_to?(:default_options) ?
                                             superclass.default_options : nil)
      end
    end

    # @api public
    module Options
      def self.included(base)
        base.class_eval { extend DefaultOptions }
      end

      attr_reader :options

      def initialize(opts = {})
        @options = ImmutableHash.new(opts, self.class.default_options)
      end
    end
  end
end
