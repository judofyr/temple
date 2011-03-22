module Temple
  module HTML
    module Dispatcher
      def on_html_staticattrs(*attrs)
        [:html, :staticattrs, *attrs.map {|k,v| [k, compile(v)] }]
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
