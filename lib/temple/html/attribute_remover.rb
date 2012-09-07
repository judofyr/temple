module Temple
  module HTML
    # This filter removes empty dynamic attributes
    # @api public
    class AttributeRemover < Filter
      default_options[:remove_empty_attrs] = true

      def call(exp)
        options[:remove_empty_attrs] ? super : exp
      end

      def on_html_attrs(*attrs)
        [:multi, *attrs.map {|attr| compile(attr) }]
      end

      def on_html_attr(name, value)
        if empty_exp?(value)
          value
        elsif contains_static?(value)
          [:html, :attr, name, value]
        else
          tmp = unique_name
          [:multi,
           [:capture, tmp, compile(value)],
           [:if, "!#{tmp}.empty?",
            [:html, :attr, name, [:dynamic, tmp]]]]
        end
      end

      private

      # Contains static
      def contains_static?(exp)
        case exp.first
        when :multi
          exp[1..-1].any? {|e| contains_static?(e) }
        when :escape
          contains_static?(exp.last)
        when :static
          true
        else
          false
        end
      end
    end
  end
end
