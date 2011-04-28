module Temple
  # == The Core Abstraction
  #
  # The core abstraction is what every template evetually should be compiled
  # to. Currently it consists of four essential and two convenient types:
  # multi, static, dynamic, code, newline and capture.
  #
  # When compiling, there's two different strings we'll have to think about.
  # First we have the generated code. This is what your engine (from Temple's
  # point of view) spits out. If you construct this carefully enough, you can
  # make exceptions report correct line numbers, which is very convenient.
  #
  # Then there's the result. This is what your engine (from the user's point
  # of view) spits out. It's what happens if you evaluate the generated code.
  #
  # === [:multi, *sexp]
  #
  # Multi is what glues everything together. It's simply a sexp which combines
  # several others sexps:
  #
  #   [:multi,
  #     [:static, "Hello "],
  #     [:dynamic, "@world"]]
  #
  # === [:static, string]
  #
  # Static indicates that the given string should be appended to the result.
  #
  # Example:
  #
  #   [:static, "Hello World"]
  #   # is the same as:
  #   _buf << "Hello World"
  #
  #   [:static, "Hello \n World"]
  #   # is the same as
  #   _buf << "Hello\nWorld"
  #
  # === [:dynamic, ruby]
  #
  # Dynamic indicates that the given Ruby code should be evaluated and then
  # appended to the result.
  #
  # The Ruby code must be a complete expression in the sense that you can pass
  # it to eval() and it would not raise SyntaxError.
  #
  # === [:code, ruby]
  #
  # Code indicates that the given Ruby code should be evaluated, and may
  # change the control flow. Any \n causes a newline in the generated code.
  #
  # === [:newline]
  #
  # Newline causes a newline in the generated code, but not in the result.
  #
  # === [:capture, variable_name, sexp]
  #
  # Evaluates the Sexp using the rules above, but instead of appending to the
  # result, it sets the content to the variable given.
  #
  # Example:
  #
  #   [:multi,
  #     [:static, "Some content"],
  #     [:capture, "foo", [:static, "More content"]],
  #     [:dynamic, "foo.downcase"]]
  #   # is the same as:
  #   _buf << "Some content"
  #   foo = "More content"
  #   _buf << foo.downcase
  class Generator
    include Mixins::Options

    default_options[:buffer] = '_buf'

    def call(exp)
      [preamble, compile(exp), postamble].join('; ')
    end

    def compile(exp)
      type, *args = exp
      if respond_to?("on_#{type}")
        send("on_#{type}", *args)
      else
        raise "Generator supports only core expressions - found #{exp.inspect}"
      end
    end

    def on_multi(*exp)
      exp.map {|e| compile(e) }.join('; ')
    end

    def on_newline
      "\n"
    end

    def on_capture(name, exp)
      options[:capture_generator].new(:buffer => name).call(exp)
    end

    def on_static(text)
      concat(text.inspect)
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

    def concat(str)
      "#{buffer} << (#{str})"
    end
  end

  module Generators
    # Implements an array buffer.
    #
    #   _buf = []
    #   _buf << "static"
    #   _buf << dynamic
    #   _buf.join
    class Array < Generator
      def preamble
        "#{buffer} = []"
      end

      def postamble
        buffer
      end
    end

    # Just like Array, but calls #join on the array.
    class ArrayBuffer < Array
      def postamble
        "#{buffer} = #{buffer}.join"
      end
    end

    # Implements a string buffer.
    #
    #   _buf = ''
    #   _buf << "static"
    #   _buf << dynamic.to_s
    #   _buf
    class StringBuffer < Array
      def preamble
        "#{buffer} = ''"
      end

      def on_dynamic(code)
        concat("(#{code}).to_s")
      end
    end

    # Implements a rails output buffer.
    #
    #   @output_buffer = ActionView::OutputBuffer
    #   @output_buffer.safe_concat "static"
    #   @output_buffer.safe_concat dynamic.to_s
    #   @output_buffer
    class RailsOutputBuffer < StringBuffer
      set_default_options :buffer_class => 'ActionView::OutputBuffer',
                          :buffer => '@output_buffer',
                          :capture_generator => RailsOutputBuffer

      def preamble
        "#{buffer} = #{options[:buffer_class]}.new"
      end

      def concat(str)
        "#{buffer}.safe_concat((#{str}))"
      end
    end
  end

  Generator.default_options[:capture_generator] = Temple::Generators::StringBuffer
end
