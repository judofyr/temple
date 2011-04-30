module Temple
  module HTML
    class Pretty < Fast
      set_default_options :indent => '  ',
                          :pretty => true,
                          :indent_tags => %w(base body dd div dl dt fieldset form head h1 h2 h3
                                             h4 h5 h6 hr html img input li link meta ol p script
                                             style table tbody td tfoot th thead title tr ul).freeze,
                          :pre_tags => %w(code pre textarea).freeze

      def initialize(opts = {})
        super
        @last = :noindent
        @indent = 0
        @pretty = options[:pretty]
        @pre_tags = Regexp.new(options[:pre_tags].map {|t| "<#{t}" }.join('|'))
      end

      def call(exp)
        @pretty ? [:multi, preamble, compile(exp)] : super
      end

      def on_static(content)
        if @pretty
          content.gsub!("\n", indent) if @pre_tags !~ content
          @last = content.sub!(/\r?\n\s*$/, ' ') ? nil : :noindent
        end
        [:static, content]
      end

      def on_dynamic(code)
        if @pretty
          @last = :noindent
          tmp = unique_name
          [:multi,
           [:code, "#{tmp} = (#{code}).to_s"],
           [:code, "#{tmp}.gsub!(\"\\n\", #{indent.inspect}) if #{@pre_tags_name} !~ #{tmp}"],
           [:dynamic, tmp]]
        else
          [:dynamic, code]
        end
      end

      def on_html_doctype(type)
        @last = nil
        super
      end

      def on_html_comment(content)
        return super unless @pretty
        @last = nil
        [:multi, [:static, indent], super]
      end

      def on_html_tag(name, attrs, closed, content)
        return super unless @pretty

        closed ||= options[:autoclose].include?(name)
        raise(InvalidExpression, "Closed tag #{name} has content") if closed && !empty_exp?(content)

        @pretty = false
        result = [:multi, [:static, "#{tag_indent(name)}<#{name}"], compile(attrs)]
        result << [:static, (closed && xhtml? ? ' /' : '') + '>']

        @pretty = !options[:pre_tags].include?(name)
        @indent += 1
        result << compile(content)
        @indent -= 1

        result << [:static, "#{tag_indent(name)}</#{name}>"] if !closed
        @pretty = true
        result
      end

      protected

      def preamble
        @pre_tags_name = unique_name
        [:code, "#{@pre_tags_name} = /#{@pre_tags.source}/"]
      end

      # Return indentation if not in pre tag
      def indent
        "\n" + (options[:indent] || '') * @indent
      end

      # Return indentation before tag
      def tag_indent(name)
        result = @last != :noindent && (options[:indent_tags].include?(@last) || options[:indent_tags].include?(name)) ? indent : ''
        @last = name
        result
      end
    end
  end
end
