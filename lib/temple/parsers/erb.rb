require 'erb'

module Temple
  module Parsers
    # Parses ERB exactly the same way as erb.rb.
    class ERB
      Compiler = ::ERB::Compiler
      
      def initialize(options = {})
        @compiler = Compiler.new(options[:trim_mode])
      end
      
      def compile(src)
        result = [:multi]
        
        content = ''
        scanner = @compiler.make_scanner(src)
        scanner.scan do |token|
          next if token.nil? 
          next if token == ''
          if scanner.stag.nil?
            case token
            when Compiler::PercentLine
              result << [:static, content] if content.size > 0
              content = ''
              result << [:block, token.to_s.strip]
              result << [:newline]
            when :cr
              result << [:newline]
            when '<%', '<%=', '<%#'
              scanner.stag = token
            when "\n"
              content << "\n"
              result << [:static, content]
              result << [:newline]
              content = ''
            when '<%%'
              result << [:static, '<%']
            else
              result << [:static, token]
              token.count("\n").times { result << [:newline] }
            end
          else
            case token
            when '%>'
              case scanner.stag
              when '<%'
                if content[-1] == ?\n
                  content.chop!
                  result << [:block, content.strip]
                  result << [:newline]
                else
                  result << [:block, content.strip]
                end
              when '<%='
                result << [:dynamic, content.strip]
              when '<%#'
                # nothing
              end
              scanner.stag = nil
              content = ''
            when '%%>'
              content << '%>'
            else
              content << token
            end
          end
        end
        
        result
      end
    end                      
  end
end