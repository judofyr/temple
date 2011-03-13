module Temple
  module Filters
    # Filter which allows the user to inject hooks into the expression transformation process
    class Hook < Filter
      def initialize(opts = {})
        super
        @hooks = options.values
      end

      def compile(exp)
        @hooks.inject(exp) do |e, hook|
          if hook.respond_to? :compile
            hook.compile(e)
          else
            hook.call(e)
          end
        end
      end
    end
  end
end
