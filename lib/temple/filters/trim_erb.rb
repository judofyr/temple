module Temple
  module Filters
    class TrimERB < Filter
      def on_multi(*exps)
        case options[:trim_mode]
        when '>'
          exps.each_cons(2) do |a, b|
            if code?(a) && static?(b)
              b[1].gsub!(/^\n/, '')
            end
          end
        when '<>'
          exps.each_with_index do |exp, i|
            if code?(exp) &&
                (!exps[i-1] || static?(exps[i-1]) && exps[i-1][1] =~ /\n$/) &&
                (exps[i+1] && static?(exps[i+1]) && exps[i+1][1] =~ /^\n/)
              exps[i+1][1].gsub!(/^\n/, '') if exps[i+1]
            end
          end
        end
        [:multi, *exps]
      end

      def code?(exp)
        exp[0] == :dynamic || exp[0] == :block
      end

      def static?(exp)
        exp[0] == :static
      end
    end
  end
end
