require 'cgi'

module Temple
  module Filters
    class Escapable
      def initialize(options = {})
        @escaper = options[:escaper] || 'CGI.escapeHTML((%s).to_s)'
      end
      
      def compile(exp)
        return exp if !exp.is_a?(Enumerable) || exp.is_a?(String)
        
        if is_escape?(exp)
          case exp[1][0]
          when :static
            [:static, eval(@escaper % exp[1][1].inspect)]
          when :dynamic
            [:dynamic, @escaper % exp[1][1]]
          else
            raise "Escapable can only handle :static and :dynamic for the moment."
          end
        else
          exp.map { |e| compile(e) }
        end
      end
      
      def is_escape?(exp)
        exp.respond_to?(:[]) && exp[0] == :escape
      end
    end
  end
end