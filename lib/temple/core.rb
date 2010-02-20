module Temple
  # == The Core Abstraction
  # 
  # The core abstraction is what every template evetually should be compiled 
  # to. Currently it consists of four essential and two convenient types:
  # multi, static, dynamic, block, newline and capture.
  # 
  # === [:multi, *exp]
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
  # Static denotes that the given string should be appended to the result.
  # 
  # === [:dynamic, rby]
  # === [:block, rby]
  # === [:newline]
  # === [:capture, name, exp]
  module Core
    #   _buf = []
    #   _buf << "static"
    #   _buf << dynamic
    #   block do
    #     _buf << "more static"
    #   end
    #   _buf.join
    class ArrayBuffer < Generator
      def preamble;  buffer " = []" end
      def postamble; buffer ".join"   end
      
      def on_static(text)
        buffer " << #{string_to_ruby text}"
      end
      
      def on_dynamic(code)
        buffer " << (#{code})"
      end
      
      def on_block(code)
        code
      end
    end
    
    # Just like ArrayBuffer, but doesn't call #join on the array.
    class Array < ArrayBuffer
      def postamble; buffer; end
    end
    
    #   _buf = ''
    #   _buf << "static"
    #   _buf << dynamic.to_s
    #   block do
    #     _buf << "more static"
    #   end
    #   _buf
    class StringBuffer < ArrayBuffer
      def preamble;  buffer " = ''" end
      def postamble; buffer end
      
      def on_dynamic(code)
        if @options[:check_literal] && Utils.literal_string?(code)
          buffer " << (#{code})"
        else
          buffer " << (#{code}).to_s"
        end
      end
    end
  end
end