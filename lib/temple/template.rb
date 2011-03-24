module Temple
  module Template
    include Mixins::DefaultOptions

    def engine(engine = nil)
      if engine
        @engine = engine
      elsif @engine
        @engine
      else
        raise 'No engine configured'
      end
    end

    def build_engine(*options)
      options << default_options
      engine.new(Utils::ImmutableHash.new(*options)) do |engine|
        chain.each {|block| engine.instance_eval(&block) }
      end
    end

    def chain(&block)
      @chain ||= []
      chain << block if block
      @chain
    end
  end
end
