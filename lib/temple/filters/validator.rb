module Temple
  module Filters
    class Validator < Filter
      default_options[:grammar] = Temple::Grammar

      def compile(exp)
        options[:grammar].validate!(exp)
        exp
      end
    end
  end
end
