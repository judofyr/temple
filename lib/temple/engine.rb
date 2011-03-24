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
  #   class SpecialEngine < MyEngine
  #     append MyCodeOptimizer
  #     replace Temple::Generators::ArrayBuffer, Temple::Generators::RailsOutputBuffer
  #   end
  #
  #   engine = MyEngine.new(:strict => "For MyParser")
  #   engine.call(something)
  #
  class Engine
    include Mixins::Options
    include Mixins::EngineDSL
    extend  Mixins::EngineDSL

    attr_reader :chain

    def self.chain
      @chain ||= superclass.respond_to?(:chain) ? superclass.chain.dup : []
    end

    def initialize(o = {})
      super
      @chain = self.class.chain.dup
      yield(self) if block_given?
      [*options[:chain]].compact.each {|block| block.call(self) }
      @chain = build_chain
    end

    def call(input)
      chain.inject(input) {|m, e| e.call(m) }
    end

    protected

    def build_chain
      chain.map do |e|
        name, filter, option_filter, local_options = e
        if Class === filter
          filtered_options = Utils::ImmutableHash.new(local_options,
              Hash[*option_filter.select {|k| options.include?(k) }.map {|k| [k, options[k]] }.flatten])
          filter.new(filtered_options)
        elsif UnboundMethod === filter
          filter.bind(self)
        else
          filter
        end
      end
    end
  end
end
