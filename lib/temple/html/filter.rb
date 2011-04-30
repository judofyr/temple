module Temple
  module HTML
    class Filter < Temple::Filter
      include Dispatcher

      dispatch :html
    end
  end
end
