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
    include Mixins::Options

    def self.filters
      @filters ||= []
    end

    def self.use(filter, *options, &block)
      filters << [filter, options, block]
    end

    # Shortcut for <tt>use Temple::Filters::parser</tt>
    def self.filter(filter, *options, &block)
      use(Temple::Filters.const_get(filter), *options, &block)
    end

    # Shortcut for <tt>use Temple::Generators::parser</tt>
    def self.generator(compiler, *options, &block)
      use(Temple::Generators.const_get(compiler), *options, &block)
    end

    def initialize(opts = {})
      super

      @chain = self.class.filters.map do |filter, opt, block|
        result = {}
        opt.each do |key|
          result[key] = options[key] if options.has_key?(key)
        end
        filter.new(result, &block)
      end
    end

    def compile(thing)
      @chain.inject(thing) { |m, e| e.compile(m) }
    end
  end
end
