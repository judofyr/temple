module Temple
  module Filters
    class StaticFreezer < Filter
      define_options freeze_static: RUBY_VERSION >= '2.1'

      def on_static(s)
        options[:freeze_static] ? [:dynamic, "#{s.inspect}.freeze"] : [:static, s]
      end
    end
  end
end
