require 'tilt'

module Temple
  # Tilt template implementation for Temple
  class Template < Tilt::Template
    class << self
      def engine(engine = nil)
        if engine
          @engine = Symbol === engine ? Temple::Engines.const_get(engine) : engine
        elsif @engine
          @engine
        else
          raise 'No engine configured'
        end
      end

      def helpers(helpers = nil)
        if helpers
          @helpers = helpers
        else
          @helpers
        end
      end
    end

    # Prepare Temple template
    #
    # Called immediately after template data is loaded.
    #
    # @return [void]
    def prepare
      @src = self.class.engine.new(options.merge(:file => eval_file)).compile(data)
    end

    # Process the template and return the result.
    #
    # Template executationis guaranteed to be performed in the scope object with the locals
    # specified and with support for yielding to the block.
    #
    # @param [Object] scope Scope object where the code is evaluated
    # @param [Hash]   locals Local variables
    # @yield Block given to the template code
    # @return [String] Evaluated template
    def evaluate(scope, locals, &block)
      helpers = self.class.helpers
      scope.instance_eval { extend helpers } if options[:helpers] && helpers
      super
    end

    # A string containing the (Ruby) source code for the template.
    #
    # @param [Hash]   locals Local variables
    # @return [String] Compiled template ruby code
    def precompiled_template(locals = {})
      @src
      end
  end
end
