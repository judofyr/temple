module Temple
  module HTML
    class Pretty < Fast
      set_default_options :indent => '  ',
                          :pretty => true,
                          :indent_tags => %w(base dd div dl doctype dt fieldset form head h1 h2 h3
                                             h4 h5 h6 hr html img input li link meta ol p script
                                             style table tbody td tfoot th thead title tr ul).freeze,
                          :pre_tags => %w(pre textarea).freeze

      def initialize(opts = {})
        super
        @last = nil
        @indent = 0
        @pretty = options[:pretty]
      end

      def compile(exp)
        [:multi, preamble, compile!(exp)]
      end

      def on_static(content)
        @last = nil
        [:static, @pretty ? content.gsub("\n", indent) : content]
      end

      def on_dynamic(content)
        @last = nil
        [:dynamic, @pretty ? "Temple::Utils.indent((#{content}), #{indent.inspect}, _temple_pre_tags)" : content]
      end

      def on_html_doctype(type)
        @last = 'doctype'
        super
      end

      def on_html_comment(content)
        return super unless @pretty
        [:multi, [:static, indent], super]
      end

      def on_html_tag(name, attrs, closed, content)
        return super unless @pretty

        closed ||= options[:autoclose].include?(name)
        raise "Closed tag #{name} has content" if closed && !empty_exp?(content)

        @pretty = false
        result = [:multi, [:static, "#{tag_indent(name)}<#{name}"], compile!(attrs)]
        result << [:static, ' /'] if closed && xhtml?
        result << [:static, '>']

        @last = name
        @pretty = !options[:pre_tags].include?(name)
        @indent += 1
        result << compile!(content)
        @indent -= 1

        result << [:static, "#{tag_indent(name)}</#{name}>"] if !closed
        @last = name
        @pretty = true
        result
      end

      protected

      def preamble
        regexp = options[:pre_tags].map {|t| "<#{t}" }.join('|')
        [:block, "_temple_pre_tags = /#{regexp}/"]
      end

      # Return indentation if not in pre tag
      def indent
        "\n" + (options[:indent] || '') * @indent
      end

      # Return indentation before tag
      def tag_indent(name)
        @last && (options[:indent_tags].include?(@last) || options[:indent_tags].include?(name)) ? indent : ''
      end
    end
  end
end
