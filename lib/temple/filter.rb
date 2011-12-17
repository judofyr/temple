module Temple
  # Temple base filter
  #
  # This class automatically implements an
  # efficient call-method. The only thing a
  # filter has to do is to implement a method
  # for every expression type if processes. If
  # a filter processes every expression of type
  # (:x, a_string) it should implement a method
  # named "on_x" with one argument.
  # Some of these methods are already implemented
  # because they are generally useful.
  #
  # To capture any unknown expression a filter
  # can implement a method named "on_unknown" with
  # variable arguments. This method will be
  # called upon every unknown expression.
  #
  # @note
  #   Processing does not reach into unknown
  #   expression types by default.
  #
  # @example
  #   class MyAwesomeFilter < Temple::Filter
  #     def on_awesome(thing) # keep awesome things
  #       return [:awesome, thing]
  #     end
  #     def on_boring(thing) # make boring things awesome
  #       return [:awesome, thing+" with bacon"]
  #     end
  #     def on_unknown(type,*args) # unknown stuff is boring too
  #       return [:awesome, 'just bacon']
  #     end
  #   end
  #   filter = MyAwesomeFilter.new
  #   # Boring things are converted:
  #   filter.call([:boring, 'egg']) #=> [:awesome, 'egg with bacon']
  #   # Unknown things too:
  #   filter.call([:foo]) #=> [:awesome, 'just bacon']
  #   # Known but not boring things won't be touched:
  #   filter.call([:awesome, 'chuck norris']) #=>[:awesome, 'chuck norris']
  #
  # @api public
  class Filter
    include Utils
    include Mixins::Dispatcher
    include Mixins::Options
  end
end
