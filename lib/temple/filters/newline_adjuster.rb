module Temple
  module Filters
    
    
    # A filter which tries to ensure, that
    # the correct number of newlines is used.
    # You can use this whenever you exchange 
    # an expression and want to make sure, 
    # that the new one occupies the same amount
    # of lines.
    #
    # @example
    #   old_tree = [:multi, [:newline], [:static, "foo"], [:newline]]
    #   # Do some uber-heavy string processing:
    #   new_tree = [:static, "bar"]
    #   # okay, the old tree had 2 newlines total and one of them was preceding: 
    #   na = Temple::Filters::NewlineAdjuster.new(:newlines => 2, :preceding_newlines =>1)
    #   na.call(new_tree) #=> [:multi, [:newline], [:static, "bar"], [:newline]]
    # 
    class NewlineAdjuster < Filter

      set_default_options :preceding_newlines => 0,
                          :succeding_newlines => 0,
                          :crop               => :tail,
                          :on_problem         => :warn

      def call(expression)
      
        if expression.nil?
          # If nothing was supplied, the solution is trivial:
          return ([[:newline]] * options[:newlines]).unshift( :multi ) 
        end
        
        os = NewlineCounter.new
        os.call(expression)
        if os.newlines >= options[:newlines]
          if os.newlines > options[:newlines]
            #TODO: implement cropping:
            #case( option[:crop] )
            #  when :tail, true then
                # remove at the end
            #  when :head then
                # remove at the head
            #  else
                # no remove
                problem{ "Can't adjust given tree to contain #{options[:newlines]} newline(s) ( it has #{os.newlines} )." }
                return expression
            #  end
          end
          # okay, nothing to do
          return expression
        else
          pre = [0, options[:preceding_newlines] - os.preceding_newlines].max
          if pre > (options[:newlines] - os.newlines)
            # would add too many newline
            pre = (options[:newlines] - os.newlines)
          end
          suc = [0, options[:newlines] - os.newlines - pre ].max
          multi = [:multi]
          multi.push( *([[:newline]]*pre) )
          multi.push( expression )
          multi.push( *([[:newline]]*suc) )
          return multi
        end
      end

      # @option options [Numeric] :newlines number of newlines the resulting expression should have
      # @option options [Numeric] :preceding_newlines number of newlines which can be inserted before the content of the expression
      # @option options [:warn,:raise,false] :on_problem what to do if the resulting expression will have too many newlines
      def initialize(options = {})
        super
        unless options[:newlines].kind_of? Numeric
          raise ArgumentError, "#{self.class} expects a :newlines option."
        end
      end

    protected
    
      def problem
        case( options[:on_problem] )
          when :warn  then warn yield
          when :raise then raise yield
        end
      end

    end
  end
end
