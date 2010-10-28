module Temple
  module Filters
    class EscapeHTML < BasicFilter
      def on_escape(type, value)
        case type
        when :static
          value = escape_html_safe(value)
        when :dynamic
          value = "Temple::Utils.escape_html#{@options[:use_html_safe] ? '_safe' : ''}((#{value}))"
        end
        [type, value]
      end
    end
  end
end
