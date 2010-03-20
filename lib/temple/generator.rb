module Temple
  class Generator
    DEFAULT_OPTIONS = {
      :buffer => "_buf"
    }
    
    CONCATABLE = [:static, :dynamic]
    
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @in_multi = false
    end
    
    def compile(exp)
      res = send("on_#{exp.first}", *exp[1..-1])
      
      if @in_multi && CONCATABLE.include?(exp.first)
        concat(res)
      else
        res
      end
    end
    
    def buffer(str = '')
      @options[:buffer] + str
    end
    
    def self.to_ruby(str)
      str.inspect.gsub(/(\\r)?\\n/m) do |str|
        if $`[-1] == ?\\
          str
        elsif $1
          "\\n"
        else
          "\n"
        end
      end
    end
    
    def to_ruby(str)
      Generator.to_ruby(str)
    end
    
    # Sensible defaults
    
    def preamble;  '' end
    def postamble; '' end
    def concat(s)  buffer " << (#{s})" end
    
    def on_multi(*exp)
      if @in_multi
        exp.map { |e| compile(e) }
      else
        @in_multi = true
        content = exp.map { |e| compile(e) }
        content = [preamble, content, postamble].flatten
        @in_multi = false
        content
      end.join(" ; ")
    end
    
    def on_newline
      "\n"
    end
    
    def on_capture(name, block)
      unless @in_multi
        # We always need the preamble/postamble in capture.
        return compile([:multi, [:capture, name, block]])
      end
      
      @in_multi = false
      prev_buffer, @options[:buffer] = @options[:buffer], name.to_s
      content = compile(block)
      
      if CONCATABLE.include?(block.first)
        "#{name} = (#{content}).to_s"
      else
        content
      end
    ensure
      @options[:buffer] = prev_buffer
    end
  end
end