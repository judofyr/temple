module Temple
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
        buffer " << #{text.inspect}"
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
        buffer " << (#{code}).to_s"
      end
    end
  end
end