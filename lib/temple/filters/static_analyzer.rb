module Temple
  module Filters
    # Convert [:dynamic, code] to [:static, text] if code is static Ruby expression.
    class StaticAnalyzer < Filter
      def call(ast)
        # Optimize only when Ripper is available.
        if ::Temple::StaticAnalyzer.available?
          super
        else
          ast
        end
      end

      def on_dynamic(code)
        if ::Temple::StaticAnalyzer.static?(code)
          [:static, eval(code).to_s]
        else
          [:dynamic, code]
        end
      end
    end
  end
end
