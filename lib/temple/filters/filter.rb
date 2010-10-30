module Temple
  module Filters
    class Filter
      include Utils
      include Mixins::Dispatcher
      include Mixins::Options
    end
  end
end
