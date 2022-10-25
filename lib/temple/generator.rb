module Temple
  # Abstract generator base class
  # Generators should inherit this class and
  # compile the Core Abstraction to ruby code.
  #
  # @api public
  class Generator
    include Utils
    include Mixins::CompiledDispatcher
    include Mixins::Options

    define_options :save_buffer,
                   capture_generator: :self,
                   buffer: '_buf',
                   freeze_static: RUBY_VERSION >= '2.1'

    def call(exp)
      [preamble, compile(exp), postamble].flatten.compact.join('; ')
    end

    def preamble
      [save_buffer, create_buffer]
    end

    def postamble
      [return_buffer, restore_buffer]
    end

    def save_buffer
      "begin; #{@original_buffer = unique_name} = #{buffer} if defined?(#{buffer})" if options[:save_buffer]
    end

    def restore_buffer
      "ensure; #{buffer} = #{@original_buffer}; end" if options[:save_buffer]
    end

    def create_buffer
    end

    def return_buffer
      'nil'
    end

    def on(*exp)
      raise InvalidExpression, "Generator supports only core expressions - found #{exp.inspect}"
    end

    def on_multi(*exp)
      exp.map {|e| compile(e) }.join('; '.freeze)
    end

    def on_newline
      "\n"
    end

    def on_capture(name, exp)
      capture_generator.new(**options, buffer: name).call(exp)
    end

    def on_static(text)
      concat(options[:freeze_static] ? "#{text.inspect}.freeze" : text.inspect)
    end

    def on_dynamic(code)
      concat(code)
    end

    def on_code(code)
      code
    end

    protected

    def buffer
      options[:buffer]
    end

    def capture_generator
      @capture_generator ||=
        case options[:capture_generator]
        when :self
          self.class
        when Class
          options[:capture_generator]
        else
          Generators.const_get(options[:capture_generator])
        end
    end

    def concat(str)
      "#{buffer} << (#{str})"
    end
  end
end
