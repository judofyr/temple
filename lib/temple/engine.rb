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

    def self.chain
      @chain ||= []
    end

    def self.use(filter, *options, &block)
      # Local option values which apply only to this filter.
      # These options cannot be overwritten by the user.
      local_opts = Hash === options.last ? options.pop : nil
      chain << proc do |opts|
        filtered_opts = Hash[*options.select {|k| opts.include?(k) }.map {|k| [k, opts[k]] }.flatten]
        filter.new(Utils::ImmutableHash.new(local_opts, filtered_opts), &block)
      end
    end

    # Shortcut for <tt>use Temple::Filters::parser</tt>
    def self.filter(filter, *options, &block)
      use(Temple::Filters.const_get(filter), *options, &block)
    end

    # Shortcut for <tt>use Temple::Generators::parser</tt>
    def self.generator(compiler, *options, &block)
      use(Temple::Generators.const_get(compiler), *options, &block)
    end

    def compile(input)
      chain.inject(input) {|m, e| e.compile(m) }
    end

    protected

    def chain
      @chain ||= self.class.chain.map { |f| f.call(options) }
    end
  end
end
