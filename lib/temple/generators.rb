module Temple
  # == The Core Abstraction
  #
  # The core abstraction is what every template evetually should be compiled
  # to. Currently it consists of four essential and two convenient types:
  # multi, static, dynamic, block, newline and capture.
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
  # === [:block, ruby]
  #
  # Block indicates that the given Ruby code should be evaluated, and may
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

    def compile(exp)
      [preamble, compile!(exp), postamble].join(' ; ')
    end

    def compile!(exp)
      type, *args = exp
      send("on_#{type}", *args)
    end

    def on_multi(*exp)
      exp.map { |e| compile!(e) }.join(' ; ')
    end

    def on_newline
      "\n"
    end

    def on_capture(name, block)
      capture_generator.new(:buffer => name).compile(block)
    end

    protected

    def capture_generator
      @capture_generator ||=
        options[:capture_generator] || Temple::Generators::StringBuffer
    end

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
    #   block do
    #     _buf << "more static"
    #   end
    #   _buf.join
    class ArrayBuffer < Generator
      def preamble;  "#{buffer} = []" end
      def postamble; "#{buffer} = #{buffer}.join" end

      def on_static(text)
        concat(text.inspect)
      end

      def on_dynamic(code)
        concat(code)
      end

      def on_block(code)
        code
      end
    end

    # Just like ArrayBuffer, but doesn't call #join on the array.
    class Array < ArrayBuffer
      def postamble; buffer; end
    end

    # Implements a string buffer.
    #
    #   _buf = ''
    #   _buf << "static"
    #   _buf << dynamic.to_s
    #   block do
    #     _buf << "more static"
    #   end
    #   _buf
    class StringBuffer < Array
      def preamble; "#{buffer} = ''" end

      def on_dynamic(code)
        concat(code) + '.to_s'
      end
    end
  end
end
