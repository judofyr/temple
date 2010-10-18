module Temple
  class Generator
    DEFAULT_OPTIONS = {
      :buffer => "_buf",
      # :capture_generator => Temple::Core::StringBuffer
      #
      # The capture generator is set in the definition of StringBuffer
      # in order to avoid circular dependencies.
    }
    
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def compile(exp)
      [preamble, compile_part(exp), postamble].join(' ; ')
    end
    
    def compile_part(exp)
      type, *args = exp
      recv = @in_capture || self
      recv.send("on_#{type}", *args)
    end
    
    def buffer(str = '')
      @options[:buffer] + str
    end

    def concat(str)
      buffer " << (#{str})"
    end

    def self.to_ruby(str)
      str.inspect
    end
    
    def to_ruby(str)
      Generator.to_ruby(str)
    end
    
    # Sensible defaults
    
    def preamble;  '' end
    def postamble; '' end
    def capture_postamble; buffer " = #{postamble}"; end
    
    def on_multi(*exp)
      exp.map { |e| compile_part(e) }.join(" ; ")
    end
    
    def on_newline
      "\n"
    end
    
    def on_capture(name, block)
      before = @capture
      @capture = @options[:capture_generator].new(:buffer => name)

      [
        @capture.preamble,
        @capture.compile_part(block),
        @capture.capture_postamble
      ].join(' ; ')
    ensure
      @capture = before
    end
  end
end

