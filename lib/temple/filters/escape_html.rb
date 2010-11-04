module Temple
  module Filters
    class EscapeHTML < Filter
      temple_dispatch :escape, :html

      # Activate the usage of html_safe if it is available (for Rails 3 for example)
      default_options[:use_html_safe] = ''.respond_to?(:html_safe)

      def on_escape_static(value)
        [:static, options[:use_html_safe] ? escape_html_safe(value) : escape_html(value)]
      end

      def on_escape_dynamic(value)
        [:dynamic, "Temple::Utils.escape_html#{options[:use_html_safe] ? '_safe' : ''}((#{value}))"]
      end

      def on_html_staticattrs(*attrs)
        [:html, :staticattrs, *attrs.map {|k,v| [k, compile!(v)] }]
      end

      def on_html_comment(content)
        [:html, :comment, compile!(content)]
      end

      def on_html_tag(name, attrs, closed, content)
        [:html, :tag, name, compile!(attrs), closed, compile!(content)]
      end
    end
  end
end
