module Temple
  class Generator
    DEFAULT_OPTIONS = {
      :buffer => "_buf",
    }
    
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @compiling = false
      @in_capture = nil
    end

    def capture_generator
      @capture_generator ||=
        @options[:capture_generator] || Temple::Core::StringBuffer
    end

    def compile(exp, single = false)
      if @compiling || single
        type, *args = exp
        recv = @in_capture || self
        recv.send("on_#{type}", *args)
      else
        begin
          @compiling = true
          [preamble, compile(exp), postamble].join(' ; ')
        ensure
          @compiling = false
        end
      end
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
    
    def on_multi(*exp)
      exp.map { |e| compile(e) }.join(" ; ")
    end
    
    def on_newline
      "\n"
    end
    
    def on_capture(name, block)
      before = @capture
      @capture = capture_generator.new(:buffer => name)

      [
        @capture.preamble,
        @capture.compile(block, true),
        "#{name} = (#{@capture.postamble})"
      ].join(' ; ')
    ensure
      @capture = before
    end
  end
end

