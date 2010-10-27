module Temple
  module Filters
    class EscapeHTML < BasicFilter
      DEFAULT_OPTIONS = {}

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def compile(exp)
        type, *args = exp
        if respond_to?("on_#{type}")
          send("on_#{type}", *args)
        else
          exp
        end
      end

      def on_multi(*exps)
        [:multi, *exps.map {|exp| compile(exp) }]
      end

      def on_escape(*exps)
        [:multi, *exps.map {|exp| compile(exp) }]
      end

      def on_capture(name, exp)
        [:capture, name, compile(exp)]
      end

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
