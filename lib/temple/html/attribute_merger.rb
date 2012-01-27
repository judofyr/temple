module Temple
  module HTML
    # @api public
    # --
    # TODO: Inherit from Filter instead; to sort attributes Temple users
    # should explicitly use AttributeSorter in the filter chain instead.
    # Since this breaks backward compatibility, it must wait until the
    # next major version.
    class AttributeMerger < AttributeSorter
      default_options[:attr_delimiter] = {'id' => '_', 'class' => ' '}

      def on_html_attrs(*attrs)
        attrs = super[2..-1]
        names = []
        result = {}
        attrs.each do |attr|
          raise(InvalidExpression, 'Attribute is not a html attr') if attr[0] != :html || attr[1] != :attr
          name, value = attr[2].to_s, attr[3]
          if result[name]
            delimiter = options[:attr_delimiter][name]
            raise "Multiple #{name} attributes specified" unless delimiter
            if empty_exp?(value)
              result[name] = [:html, :attr, name,
                              [:multi,
                               result[name][3],
                               value]]
            elsif contains_static?(value)
              result[name] = [:html, :attr, name,
                              [:multi,
                               result[name][3],
                               [:static, delimiter],
                               value]]
            else
              tmp = unique_name
              result[name] = [:html, :attr, name,
                              [:multi,
                               result[name][3],
                               [:capture, tmp, value],
                               [:if, "!#{tmp}.empty?",
                                [:multi,
                                 [:static, delimiter],
                                 [:dynamic, tmp]]]]]
            end
          else
            result[name] = attr
            names << name
          end
        end
        [:multi, *names.map {|name| compile(result[name]) }]
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

      protected

      def contains_static?(exp)
        case exp[0]
        when :multi
          exp[1..-1].any? {|e| contains_static?(e) }
        when :escape
          contains_static?(exp[2])
        when :static
          true
        else
          false
        end
      end
    end
  end
end
