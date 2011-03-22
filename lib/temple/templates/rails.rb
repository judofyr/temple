if ::Rails::VERSION::MAJOR < 3
  raise "Temple supports only Rails 3.x and greater, your Rails version is #{::Rails::VERSION::STRING}"
end

module Temple
  module Templates
    if ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR < 1
      class Rails < ActionView::TemplateHandler
        include ActionView::TemplateHandlers::Compilable
        extend Temple::Template

        def compile(template)
          self.class.engine.new(self.class.default_options).call(template.source)
        end

        def self.register(name)
          ActionView::Template.register_template_handler name.to_sym, self
        end
      end
    else
      class Rails
        extend Temple::Template

        def self.call(template)
          engine.new(default_options).call(template.source)
        end

        def self.register(name)
          ActionView::Template.register_template_handler name.to_sym, self
        end
      end
    end
  end
end
