module Temple
  module HTML
    module Dispatcher
      def on_html_attrs(*attrs)
        [:html, :attrs, *attrs.map {|a| compile(a) }]
      end

      def on_html_attr(name, content)
        [:html, :attr, name, compile(content)]
      end

      # WARNING: [:html, :staticattrs, ...] is deprecated
      # Translate to [:html, :attrs]
      def on_html_staticattrs(*attrs)
        compile([:html, :attrs, *attrs.map {|k,v| [:html, :attr, k, v] }])
      end

      def on_html_comment(content)
        [:html, :comment, compile(content)]
      end

      def on_html_tag(name, attrs, closed, content)
        [:html, :tag, name, compile(attrs), closed, compile(content)]
      end
    end
  end
end
