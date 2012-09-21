module Temple
  module Mixins
    # @api private
    module Template
      include DefaultOptions

      def compile(code, options)
        raise 'No engine configured' unless default_options[:engine]
        default_options[:engine].new(options).call(code)
      end

      def init
        # Overwrite this for class initialization
      end

      def register_as(name)
        raise NotImplementedError
      end

      def create(engine, options)
        template = Class.new(self)
        template.disable_option_validator!
        template.default_options[:engine] = engine
        template.default_options.update(options)
        template.init
        template.register_as(options[:register_as]) if options[:register_as]
        template
      end
    end
  end
end
