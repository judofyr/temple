require 'tilt'

module Temple
  # Tilt template implementation for Temple
  class Template < Tilt::Template
    class << self
      def engine(engine = nil)
        if engine
          @engine = engine
        elsif @engine
          @engine
        else
          raise 'No engine configured'
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

    # A string containing the (Ruby) source code for the template.
    #
    # @param [Hash]   locals Local variables
    # @return [String] Compiled template ruby code
    def precompiled_template(locals = {})
      @src
      end
  end
end
