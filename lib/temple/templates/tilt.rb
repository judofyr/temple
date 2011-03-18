require 'tilt'

module Temple
  module Templates
    class Tilt < ::Tilt::Template
      extend Temple::Template

      # Prepare Temple template
      #
      # Called immediately after template data is loaded.
      #
      # @return [void]
      def prepare
        opts = Utils::ImmutableHash.new({ :file => eval_file }, options, self.class.default_options)
        @src = self.class.engine.new(opts).compile(data)
      end

      # A string containing the (Ruby) source code for the template.
      #
      # @param [Hash]   locals Local variables
      # @return [String] Compiled template ruby code
      def precompiled_template(locals = {})
        @src
      end

      def self.register(name)
        ::Tilt.register name.to_s, self
      end
    end
  end
end
