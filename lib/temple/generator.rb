module Temple
  class Generator
    DEFAULT_OPTIONS = {
      :buffer => "_buf"
    }
    
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
    end
    
    def compile(exp)
      [preamble, compile_part(exp), postamble].join(" ; ")
    end
    
    def compile_part(exp)
      send("on_#{exp.first}", *exp[1..-1])
    end
    
    def buffer(str = '')
      @options[:buffer] + str
    end
    
    # Sensible defaults
    
    def preamble;  '' end
    def postamble; '' end
    
    def on_multi(*exp)
      exp.map { |e| compile_part(e) }.join(" ; ")
    end
    
    def on_newline
      "\n"
    end
  end
end