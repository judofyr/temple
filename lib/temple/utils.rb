module Temple
  module Utils
    extend self

    def empty_exp?(exp)
      case exp[0]
      when :multi
        exp[1..-1].all? { |e| e[0] == :newline }
      else
        false
      end
    end
  end
end
