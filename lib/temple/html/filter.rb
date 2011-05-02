module Temple
  module HTML
    # @api public
    class Filter < Temple::Filter
      include Dispatcher

      dispatch :html
    end
  end
end
