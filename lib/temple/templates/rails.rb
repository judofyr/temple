unless defined?(ActionView)
  raise "Rails is not loaded - Temple::Templates::Rails cannot be used"
end

if ::ActionPack::VERSION::MAJOR < 3 || ::ActionPack::VERSION::MAJOR == 3 && ::ActionPack::VERSION::MINOR < 1
  raise "Temple supports only Rails 3.1 and greater, your Rails version is #{::ActionPack::VERSION::STRING}"
end

module Temple
  module Templates
    class Rails
      extend Mixins::Template

      def call(template)
        opts = {}.update(self.class.options).update(:file => template.identifier)
        self.class.compile(template.source, opts)
      end

      def supports_streaming?
        self.class.options[:streaming]
      end

      def self.register_as(*names)
        names.each do |name|
          ActionView::Template.register_template_handler name.to_sym, new
        end
      end
    end
  end
end
