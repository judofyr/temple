module Temple
  module HTML
    class Pretty < Fast
      set_default_options :indent => '  ',
                          :pretty => true

      INDENT_TAGS = %w(base div doctype form head html img input li link meta ol
                       script style table tbody td th thead title tr ul).freeze

      def initialize(opts = {})
        super
        @last = nil
        @stack = []
      end

      def on_static(content)
        if options[:pretty]
          @last = nil
          [:static, content.gsub("\n", indent)]
        else
          [:static, content]
        end
      end

      def on_dynamic(content)
        if options[:pretty]
          @last = nil
          [:dynamic, %{(#{content}).to_s.gsub("\n", #{indent.inspect})}]
        else
          [:dynamic, content]
        end
      end

      def on_html_doctype(type)
        @last = 'doctype'
        super
      end

      def on_html_comment(content)
        return super if !options[:pretty]
        [:multi, [:static, indent], super]
      end

      def on_html_tag(name, attrs, closed, content)
        return super if !options[:pretty]

        closed ||= options[:autoclose].include?(name)
        raise "Closed tag #{name} has content" if closed && !empty_exp?(content)

        result = [:multi, [:static, "#{tag_indent(name)}<#{name}"], compile!(attrs)]
        result << [:static, ' /'] if closed && xhtml?
        result << [:static, '>']

        @stack << name
        @last = name
        result << compile!(content)
        @stack.pop

        result << [:static, "#{tag_indent(name)}</#{name}>"] if !closed
        @last = name
        result
      end

      # Return indentation if not in pre tag
      def indent
        @stack.include?('pre') ? '' : ("\n" + ((options[:indent] || '') * @stack.size))
      end

      # Return indentation before tag
      def tag_indent(name)
        @last && (INDENT_TAGS.include?(@last) || INDENT_TAGS.include?(name)) ? indent : ''
      end
    end
  end
end
