# frozen_string_literal: true
module Temple
  module Filters
    # Remove BOM from input string
    #
    # @api public
    class RemoveBOM < Parser
      def call(s)
        return s unless /^UTF-(8|16|32)(BE|LE)?/.match?(s.encoding.name)
        s.gsub(Regexp.new("\\A\uFEFF".encode(s.encoding.name)), ''.freeze)
      end
    end
  end
end
