require 'tilt'

module Temple
  module Templates
    class Tilt < ::Tilt::Template
      extend Mixins::Template

      define_options :mime_type => 'text/html'

      def self.default_mime_type
        default_options[:mime_type]
      end

      def self.default_mime_type=(mime_type)
        default_options[:mime_type] = mime_type
      end

      # Prepare Temple template
      #
      # Called immediately after template data is loaded.
      #
      # @return [void]
      def prepare
        # Overwrite option: No streaming support in Tilt
        @src = self.class.compile(data, ImmutableHash.new({ :file => eval_file, :streaming => false },
                                  options, self.class.default_options).without(:mime_type, :engine))
      end

      # A string containing the (Ruby) source code for the template.
      #
      # @param [Hash]   locals Local variables
      # @return [String] Compiled template ruby code
      def precompiled_template(locals = {})
        @src
      end

      def self.register_as(*names)
        ::Tilt.register(self, *names.map(&:to_s))
      end
    end
  end
end
