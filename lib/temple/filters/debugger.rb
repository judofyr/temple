module Temple
  module Filters
    # Filter which prints Temple expression
    class Debugger < Filter
      default_options[:debug_pretty] = true

      def initialize(opts = {})
        super
        require 'pp' if options[:debug_pretty]
      end

      def compile(exp)
        if options[:debug]
          puts options[:debug_prefix] if options[:debug_prefix]
          if options[:debug_pretty]
            pp exp
          else
            p exp
          end
          puts
        end
        exp
      end
    end
  end
end
