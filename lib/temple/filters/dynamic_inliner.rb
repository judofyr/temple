module Temple
  module Filters
    # Inlines several static/dynamic into a single dynamic.
    class DynamicInliner < BasicFilter
      def on_multi(*exps)
        res = [:multi]
        curr = nil
        prev = []
        state = :looking

        # We add a noop because we need to do some cleanup at the end too.
        (exps + [:noop]).each do |exp|
          head, arg = exp

          case head
          when :newline
            case state
            when :looking
              # We haven't found any static/dynamic, so let's just add it
              res << exp
            when :single, :several
              # We've found something, so let's make sure the generated
              # dynamic contains a newline by escaping a newline and
              # starting a new string:
              #
              # "Hello "\
              # "#{@world}"
              prev << exp
              curr[1] << "\"\\\n\""
            end
          when :dynamic, :static
            case state
            when :looking
              # Found a single static/dynamic.  We don't want to turn this
              # into a dynamic yet.  Instead we store it, and if we find
              # another one, we add both then.
              state = :single
              prev = [exp]
              curr = [:dynamic, '"' + send(head, arg)]
            when :single
              # Yes! We found another one.  Append the content to the current
              # dynamic and add it to the result.
              curr[1] << send(head, arg)
              res << curr
              state = :several
            when :several
              # Yet another dynamic/single.  Just add it now.
              curr[1] << send(head, arg)
            end
          else
            # We need to add the closing quote.
            curr[1] << '"' unless state == :looking
            # If we found a single exp last time, let's add it.
            res.concat(prev) if state == :single
            # Compile the current exp (unless it's the noop)
            res << compile(exp) unless head == :noop
            # Now we're looking for more!
            state = :looking
          end
        end

        res
      end

      def static(str)
        Generator.to_ruby(str)[1..-2]
      end

      def dynamic(str)
        '#{%s}' % str
      end
    end
  end
end
