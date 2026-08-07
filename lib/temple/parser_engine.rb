# frozen_string_literal: true

module Temple
  temple_parser_engine = ENV['TEMPLE_PARSER_ENGINE']

  prism_available =
    if !temple_parser_engine || temple_parser_engine == 'prism'
      begin
        require 'prism'
        true
      rescue LoadError
      end
    end

  ripper_available =
    if !temple_parser_engine || temple_parser_engine == 'ripper'
      begin
        require 'ripper'
        Ripper.respond_to?(:lex)
      rescue LoadError
      end
    end

  PARSER_ENGINE =
    if prism_available
      :prism
    elsif ripper_available
      :ripper
    else
      :none
    end

  private_constant :PARSER_ENGINE
end
