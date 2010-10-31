module Temple
  module Filters
    # Filter which prints Temple expression
    class Debugger < Filter
      def compile(exp)
        if options[:debug]
          puts options[:prefix] if options[:prefix]
          puts exp.inspect
          puts
        end
        exp
      end
    end
  end
end
