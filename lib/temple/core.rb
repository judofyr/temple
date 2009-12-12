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
      def preamble;  buffer " = []\n" end
      def postamble; buffer ".join"   end
      
      def on_static(text)
        buffer " << #{text.inspect}\n"
      end
      
      def on_dynamic(code)
        buffer " << (#{code})\n"
      end
      
      def on_block(code)
        code + "\n"
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
      def preamble;  buffer " = ''\n" end
      def postamble; buffer end
      
      def on_dynamic(code)
        buffer " << (#{code}).to_s\n"
      end
    end
    
    # Compiles into a single double-quoted string.
    #
    # This doesn't make so much sense when you have blocks, so it's
    # kinda funky.  You probably want to use Filters::DynamicInliner instead.
    # For now, check out the source for #on_multi.
    class Interpolation < Generator
      def preamble;  '"' end
      def postamble; '"' end
      
      def on_static(text)
        text.inspect[1..-2]
      end
      
      def on_dynamic(code)
        '#{%s}' % code
      end
      
      def on_multi(*exps)
        if exps.detect { |exp| exp[0] == :block }
          '#{%s}' % exps.map do |exp|
            if exp[0] == :block
              exp[1]
            else
              compile(exp)
            end
          end.join
        else
          super
        end  
      end
      
      def on_block(code)
        '#{%s;nil}' % code
      end
    end
  end
end