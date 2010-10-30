module Temple
  module Filters
    class EscapeHTML < Filter
      def on_escape(type, value)
        case type
        when :static
          value = @options[:user_html_safe] ? escape_html_safe(value) : escape_html(value)
        when :dynamic
          value = "Temple::Utils.escape_html#{@options[:use_html_safe] ? '_safe' : ''}((#{value}))"
        end
        [type, value]
      end
    end
  end
end
