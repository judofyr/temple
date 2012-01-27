module Temple
  module HTML
    # @api public
    class AttributeSorter < Filter
      default_options[:sort_attrs] = true

      def on_html_attrs(*attrs)
        if options[:sort_attrs]
          attrs.sort_by! do |attr|
            raise(InvalidExpression, 'Attribute is not a html attr') if attr[0] != :html || attr[1] != :attr
            attr[2].to_s
          end
        end

        [:html, :attrs, *attrs]
      end
    end
  end
end
