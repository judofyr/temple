require 'irb/ruby-lex'
require 'stringio'

module Temple
  module Utils
    extend self
    
    LITERAL_TOKENS = [RubyToken::TkSTRING, RubyToken::TkDSTRING]
    
    def literal_string?(str)
      lexer = RubyLex.new
      lexer.set_input(StringIO.new(str.strip))
      
      # The first token has to be a string.
      LITERAL_TOKENS.include?(lexer.token.class) and
      # That has to be the only token.
      lexer.token.nil?
    end
  end
end