module Temple
  module Filters
    # Escape dynamic or static expressions.
    # This filter must be used after Temple::HTML::* and before the generators.
    # It can be enclosed with Temple::Filters::DynamicInliner filters to
    # reduce calls to Temple::Utils#escape_html.
    class EscapeHTML < Filter
      # Activate the usage of html_safe? if it is available (for Rails 3 for example)
      default_options[:use_html_safe] = ''.respond_to?(:html_safe?)

      def initialize(opts = {})
        super
        @escape = false
      end

      def on_escape(flag, exp)
        old = @escape
        @escape = flag
        compile(exp)
      ensure
        @escape = old
      end

      def on_static(value)
        [:static, @escape ? (options[:use_html_safe] ? escape_html_safe(value) : escape_html(value)) : value]
      end

      def on_dynamic(value)
        [:dynamic, @escape ? "Temple::Utils.escape_html#{options[:use_html_safe] ? '_safe' : ''}((#{value}))" : value]
      end
    end
  end
end
