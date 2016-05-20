begin
  require 'ripper'
rescue LoadError
end

module Temple
  module Filters
    # Convert [:dynamic, code] to [:static, text] if code is static Ruby expression.
    class StaticAnalyzer < Filter
      STATIC_TOKENS = [
        :on_tstring_beg, :on_tstring_end, :on_tstring_content,
        :on_embexpr_beg, :on_embexpr_end,
        :on_lbracket, :on_rbracket,
        :on_qwords_beg, :on_words_sep, :on_qwords_sep,
        :on_lparen, :on_rparen,
        :on_lbrace, :on_rbrace, :on_label,
        :on_int, :on_float, :on_imaginary,
        :on_comma, :on_sp,
      ].freeze

      DYNAMIC_TOKENS = [
        :on_ident, :on_period,
      ].freeze

      STATIC_KEYWORDS = [
        'true', 'false', 'nil',
      ].freeze

      STATIC_OPERATORS = [
        '=>',
      ].freeze

      if defined?(Ripper)
        def self.static?(code)
          return false if code.nil? || code.strip.empty?
          return false if SyntaxChecker.syntax_error?(code)

          Ripper.lex(code).each do |(_, col), token, str|
            case token
            when *STATIC_TOKENS
              # noop
            when :on_kw
              return false unless STATIC_KEYWORDS.include?(str)
            when :on_op
              return false unless STATIC_OPERATORS.include?(str)
            when *DYNAMIC_TOKENS
              return false
            else
              return false
            end
          end
          true
        end

        def on_dynamic(code)
          if StaticAnalyzer.static?(code)
            [:static, eval(code).to_s]
          else
            [:dynamic, code]
          end
        end

        class SyntaxChecker < Ripper
          class ParseError < StandardError; end

          def self.syntax_error?(code)
            self.new(code).parse
            false
          rescue ParseError
            true
          end

          private

          def on_parse_error(*)
            raise ParseError
          end
        end
      else
        # Do nothing if ripper is unavailable
        def call(ast)
          ast
        end
      end
    end
  end
end
