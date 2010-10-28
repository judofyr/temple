module Temple
  class Generator
    include Mixins::Options

    default_options[:buffer] = '_buf'

    def initialize(options = {})
      super
      @compiling = false
    end

    def capture_generator
      @capture_generator ||=
        @options[:capture_generator] || Temple::Core::StringBuffer
    end

    def compile(exp)
      if @compiling
        type, *args = exp
        send("on_#{type}", *args)
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
      capture_generator.new(:buffer => name).compile(block)
    end
  end
end

