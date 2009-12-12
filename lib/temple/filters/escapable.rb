module Temple
  module Filters
    class Escapable
      def initialize(options = {})
        @escaper = options[:escaper] || 'CGI.escapeHTML(%s.to_s)'
      end
      
      def compile(exp)
        return exp if !exp.is_a?(Enumerable) || exp.is_a?(String)
        
        if exp[0] == :static && is_escape?(exp[1])
          [:static, eval(@escaper % exp[1][1].inspect)]
        elsif is_escape?(exp)
          @escaper % exp[1]
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