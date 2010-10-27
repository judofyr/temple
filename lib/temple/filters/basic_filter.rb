module Temple
  module Filters
    class BasicFilter
      include Utils

      def initialize(options = {})
        @options = options
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

      def on_capture(name, exp)
        [:capture, name, compile(exp)]
      end
    end
  end
end

