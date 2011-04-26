module Temple
  module HTML
    class Filter < Temple::Filter
      include Dispatcher

      temple_dispatch :html
    end
  end
end
