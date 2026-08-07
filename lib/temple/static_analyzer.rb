# frozen_string_literal: true
require 'temple/parser_engine'

module Temple
  module StaticAnalyzer
    if PARSER_ENGINE == :prism
      class << self
        def available?
          true
        end

        def static?(code)
          return false if code.nil? || code.strip.empty?
          (result = Prism.parse(code)).success? && static_node?(result.value)
        end

        def syntax_error?(code)
          !Prism.parse_success?(code)
        end

        private

        def static_node?(node)
          case node.type
          when :program_node
            static_node?(node.statements)
          when :parentheses_node
            (stmts = node.body).is_a?(Prism::StatementsNode) &&
              static_node?(stmts)
          when :statements_node
            node.body.size == 1 && static_node?(node.body.first)
          when :interpolated_string_node
            node.parts.all? { |part| static_node?(part) }
          when :embedded_statements_node
            (stmts = node.statements) && static_node?(stmts)
          when :array_node
            node.elements.all? { |elem| static_node?(elem) }
          when :hash_node, :keyword_hash_node
            node.elements.all? { |elem| static_node?(elem) }
          when :assoc_node
            static_node?(node.key) && static_node?(node.value)
          when :string_node, :integer_node, :float_node, :imaginary_node,
               :rational_node, :symbol_node, :true_node, :false_node, :nil_node
            true
          else
            false
          end
        end
      end
    elsif PARSER_ENGINE == :ripper
      STATIC_TOKENS = [
        :on_tstring_beg, :on_tstring_end, :on_tstring_content,
        :on_embexpr_beg, :on_embexpr_end,
        :on_lbracket, :on_rbracket,
        :on_qwords_beg, :on_words_sep, :on_qwords_sep,
        :on_lparen, :on_rparen,
        :on_lbrace, :on_rbrace, :on_label,
        :on_int, :on_float, :on_imaginary,
        :on_comma, :on_sp, :on_ignored_nl,
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

      class << self
        def available?
          true
        end

        def static?(code)
          return false if code.nil? || code.strip.empty? || syntax_error?(code)

          Ripper.lex(code).each do |_, token, str|
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

        def syntax_error?(code)
          SyntaxChecker.new(code).parse
          false
        rescue SyntaxChecker::ParseError
          true
        end

        class SyntaxChecker < Ripper
          class ParseError < StandardError; end

          private

          def on_parse_error(*)
            raise ParseError
          end
        end
      end
    else
      class << self
        def available?
          false
        end
      end
    end
  end
end
