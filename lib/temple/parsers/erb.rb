module Temple
  module Parsers
    # A dead simple ERB parser which compiles directly to Core.
    # It's crappy, but it works for now.
    class ERB
      def compile(src)
        result = [:multi]
        while src =~ /<%(.*?)%>/
          result << [:static, $`]
          text = $1[1..-1].strip
          case $1[0]
          when ?#
            next
          when ?=
            text = [:escape, text] if $1[1] == ?=
            head = :dynamic
          else
            head = :block
          end
          result << [head, text]
          src = $'
        end
        result << [:static, src]
        result
      end
    end                      
  end
end