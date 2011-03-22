module Temple
  module Filters
    # Filter which allows the user to inject hooks into the expression transformation process
    class Hook < Filter
      def initialize(opts = {})
        super
        @hooks = options.values
      end

      def call(exp)
        @hooks.inject(exp) {|e, hook| hook.call(e) }
      end
    end
  end
end
