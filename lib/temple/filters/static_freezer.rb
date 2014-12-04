module Temple
  module Filters
    class StaticFreezer < Filter
      def on_static(str)
        [:dynamic, "#{str.inspect}.freeze"]
      end
    end
  end
end
