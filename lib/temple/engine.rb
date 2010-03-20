module Temple
  # An engine is simply a chain of compilers (that includes both parsers,
  # filters and generators).
  #
  #   class ERB < Temple::Engine
  #     parser :ERB            # shortcut for use Temple::Parsers::ERB
  #     filter :Escapable      #              use Temple::Filters::Escapable
  #     filter :DynamicInliner #              use Temple::Filters::DynamicInliner
  #     generator :ArrayBuffer  #              use Temple::Core::ArrayBuffer
  #  end
  class Engine
    def self.filters
      @filters ||= []
    end
    
    def self.use(filter, *args, &blk)
      filters << [filter, args, blk]
    end
    
    def self.parser(parser, *args, &blk)
      use(Temple::Parsers.const_get(parser), *args, &blk)
    end
    
    def self.filter(filter, *args, &blk)
      use(Temple::Filters.const_get(filter), *args, &blk)
    end
    
    def self.generator(compiler, *args, &blk)
      use(Temple::Core.const_get(compiler), *args, &blk)
    end
    
    def initialize(options = {})
      @chain = self.class.filters.map do |filter, args, blk|
        opt = args.last.is_a?(Hash) ? args.pop : {}
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