module Temple
  module Parsers
    # A Mustache parser which compiles into Mustache-nodes:
    # 
    #   {{ name }}      # => [:mustache, :evar, :name]
    #   {{{ name }}}    # => [:mustache, :var, :name]
    #   {{#name}} code {{/name}} # => [:mustache, :section, :name, code]
    #   {{> simple }}   # => [:mustache, :partial, :simple]
    class Mustache
      attr_accessor :otag, :ctag
      
      def compile(src)
        res = [:multi]
        while src =~ /#{otag}\#([^\}]*)#{ctag}\s*(.+?)#{otag}\/\1#{ctag}\s*/m
          # $` = The string to the left of the last successful match
          res << compile_tags($`)
          name = $1.strip.to_sym
          code = compile($2)
          res << [:mustache, :section, name, code]
          # $' = The string to the right of the last successful match
          src = $'
        end
        res << compile_tags(src)
      end
      
      def compile_tags(src)
        res = [:multi]
        while src =~ /#{otag}(#|=|!|<|>|\{)?(.+?)\1?#{ctag}+/
          res << [:static, $`]
          case $1
          when '#'
            raise "Unclosed section"
          when '!'
            # ignore comments
          when '='
            self.otag, self.ctag = $2.strip.split(' ', 2)
          when '>', '<'
            res << [:mustache, :partial, $2.strip.to_sym]
          when '{'
            res << [:mustache, :var, $2.strip.to_sym]
          else
            res << [:mustache, :evar, $2.strip.to_sym]
          end
          src = $'
        end
        res << [:static, src]
      end
      
      # {{ - opening tag delimiter
      def otag
        @otag ||= Regexp.escape('{{')
      end

      def otag=(tag)
        @otag = Regexp.escape(tag)
      end

      # }} - closing tag delimiter
      def ctag
        @ctag ||= Regexp.escape('}}')
      end

      def ctag=(tag)
        @ctag = Regexp.escape(tag)
      end
    end
  end
end