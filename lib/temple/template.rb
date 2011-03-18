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
  end
end
