module Temple
  # An engine is simply a chain of compilers (that often includes a parser,
  # some filters and a generator).
  #
  #   class MyEngine < Temple::Engine
  #     # First run MyParser, passing the :strict option
  #     use MyParser, :strict
  # 
  #     # Then a custom filter
  #     use MyFilter
  #      
  #     # Then some general optimizations filters
  #     filter :MultiFlattener
  #     filter :StaticMerger
  #     filter :DynamicInliner
  #       
  #     # Finally the generator
  #     generator :ArrayBuffer, :buffer
  #   end
  #   
  #   engine = MyEngine.new(:strict => "For MyParser")
  #   engine.compile(something)
  # 
  class Engine
    def self.filters
      @filters ||= []
    end
    
    def self.use(filter, *args, &blk)
      filters << [filter, args, blk]
    end
    
    # Shortcut for <tt>use Temple::Parsers::parser</tt>
    def self.parser(parser, *args, &blk)
      use(Temple::Parsers.const_get(parser), *args, &blk)
    end
    
    # Shortcut for <tt>use Temple::Filters::parser</tt>
    def self.filter(filter, *args, &blk)
      use(Temple::Filters.const_get(filter), *args, &blk)
    end
    
    # Shortcut for <tt>use Temple::Generator::parser</tt>
    def self.generator(compiler, *args, &blk)
      use(Temple::Core.const_get(compiler), *args, &blk)
    end
    
    def initialize(options = {})
      @chain = self.class.filters.map do |filter, args, blk|
        opt = args.last.is_a?(Hash) ? args.last : {}
        opt = args.inject(opt) do |memo, ele|
          memo[ele] = options[ele] if options.has_key?(ele)
          memo
        end
        
        filter.new(opt, &blk)
      end
    end
    
    def compile(thing)
      @chain.inject(thing) { |m, e| e.compile(m) }
    end
  end
end
