module Temple
  module Filters
    # A filter which counts how many lines a certain
    # expression will occupy in the final code.
    # Does not alter the expression.
    #
    # For unknown expression it assumes that they
    # generate code and occupy exactly the number
    # of newlines their inner expressions contain.
    #
    # @example counts :newline
    #   nc = Temple::Filters::NewlineCounter.new
    #   nc.call([:multi, [:newline] ])
    #   nc.newlines #=> 1
    #
    # @example counts :code / :dynamic
    #   nc = Temple::Filters::NewlineCounter.new
    #   nc.call([:code, 'foo\n\nbar'])
    #   nc.newlines #=> 2
    #
    class NewlineCounter < Temple::Filter

      # Remove most of the default things
      self.instance_methods.each do |m|
        m = m.to_s
        if m =~ /\Aon/ and m != 'on_multi'
          eval "undef #{m}"
        end
      end

      # total number of lines
      # @api public
      attr_reader :newlines

      # number of lines before the first not-empty
      # line will appear
      #
      # @api public
      #
      # @example
      #   nc = Temple::Filters::NewlineCounter.new
      #   nc.call([:multi, [:newline], [:newline], [:code, "42"]])
      #   nc.preceding_newlines #=> 2
      attr_reader :preceding_newlines

      # number of empty lines after the last
      # not-empty line
      #
      # This will be 0 if the expression will just
      # contain empty lines ( or no lines at all ).
      # You can check this with {#only_newlines?}.
      #
      # @api public
      #
      # @example
      #   nc = Temple::Filters::NewlineCounter.new
      #   nc.call([:multi, [:newline], [:code, '42'], [:newline]])
      #   nc.succeding_newlines #=> 1
      #
      # @example succeding newlines is 0 without code:
      #   nc = Temple::Filters::NewlineCounter.new
      #   nc.call([:multi, [:newline], [:newline]])
      #   nc.succeding_newlines #=> 0
      attr_reader :succeding_newlines

      # did the expression contained only newlines?
      #
      # Return true when the expression contained only
      # empty lines.
      #
      # @api public
      #
      # @example
      #   nc = Temple::Filters::NewlineCounter.new
      #   nc.call([:multi, [:newline], [:newline]])
      #   nc.only_newlines? #=> true
      #
      # @example
      #   nc = Temple::Filters::NewlineCounter.new
      #   nc.call([:code , "42"])
      #   nc.only_newlines? #=> false
      def only_newlines?
        return !@code_found
      end

      # Resets {#newlines}, {#preceding_newlines}, {#succeding_newlines} and {#only_newlines?}
      def reset!
        @code_found = false
        @newlines = 0
        @preceding_newlines = 0
        @succeding_newlines = 0
      end

      # Tries to match the number of newlines in a tree with
      # the number of newlines in the tree supplied to the last
      # call. This is neccessary to keep correct line numberings
      # for following content
      #
      # Under the hood this method uses a NewlineAdjuster.
      #
      # @example
      #   original = [:multi, [:newline], [:static, "abc"], [:newline]]
      #   lc = Temple::Filters::NewlineCounter.new
      #   lc.call( original )
      #   new_tree = [:static, 'cba']
      #   # et voila! Correct number of newlines:
      #   lc.adjust_newlines(new_tree) #=> [:multi, [:newline], [:static, "cba"], [:newline]]
      #
      # @see Temple::Filters::NewlineAdjuster
      # @api public
      # @param [Array, nil] expression a temple expression
      # @param [Hash] options options for the adjuster
      def adjust_newlines(expression=nil, options={})
        newline_adjuster(options).call(expression)
      end

      # Creates a {Temple::Filters::NewlineAdjuster}
      # with the settings of this filter ( number of
      # newlines, preceding newlines ... ).
      #
      # For options see {Temple::Filters::NewlineAdjuster}
      #
      # @api public
      # @param [Hash] options
      # @return {Temple::Filters::NewlineAdjuster}
      def newline_adjuster(options={})
        NewlineAdjuster.new({:newlines => newlines, :preceding_newlines => preceding_newlines, :succeding_newlines => succeding_newlines}.merge(options))
      end

      # @api private
      def on_newline
        newline!
        return [:newline]
      end

      # @api private
      def on_dynamic(body)
        body.lines.each do |line|
          if line[-1,1] == NEWLINE
            newline!
          end
        end
        return [:dynamic,body]
      end

      # @api private
      def on_code(body)
        body.lines.each do |line|
          if line != NEWLINE
            code!
          end
          if line[-1,1] == NEWLINE
            newline!
          end
        end
        return [:code,body]
      end

      # @api private
      def on(*tree)
        # assume that no tag is passed without generating code
        code!
        tree.each do |x|
          if x.kind_of? Array
            call(x)
          end
        end
        return tree
      end

    private
      def initialize(*_)
        super
        reset!
      end

      # @api private
      NEWLINE = "\n".freeze

      def newline!
        if @code_found
          @succeding_newlines += 1
        else
          @preceding_newlines += 1
        end
        @newlines += 1
      end

      def code!
        @code_found = true
        @succeding_newlines = 0
      end
    end
  end
end
