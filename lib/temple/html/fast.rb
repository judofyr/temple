module Temple
  module HTML
    class Fast < Filters::BasicFilter
      temple_dispatch :html

      XHTML_DOCTYPES = {
        '1.1'          => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
        '5'            => '<!DOCTYPE html>',
        'strict'       => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
        'frameset'     => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
        'mobile'       => '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">',
        'basic'        => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">',
        'transitional' => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
      }.freeze

      HTML4_DOCTYPES = {
        'strict'       => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
        'frameset'     => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">',
        'transitional' => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
      }.freeze

      set_default_options :format => :xhtml,
                          :attr_wrapper => "'",
                          :autoclose => %w[meta img link br hr input area param col base]

      def initialize(options = {})
        super
        unless [:xhtml, :html4, :html5].include?(@options[:format])
          raise "Invalid format #{@options[:format].inspect}"
        end
      end

      def xhtml?
        @options[:format] == :xhtml
      end

      def html?
        html5? or html4?
      end

      def html5?
        @options[:format] == :html5
      end

      def html4?
        @options[:format] == :html4
      end

      def on_html_doctype(type)
        trailing_newlines = type[/(\A|[^\r])(\n+)\Z/, 2].to_s

        text = type.to_s.downcase.strip
        if text =~ /^xml/
          raise 'Invalid xml directive in html mode' if html?
          wrapper = @options[:attr_wrapper]
          str = "<?xml version=#{wrapper}1.0#{wrapper} encoding=#{wrapper}#{text.split(' ')[1] || "utf-8"}#{wrapper} ?>"
        else
          case @options[:format]
          when :html5
            str = '<!DOCTYPE html>'
          when :html4
            str = HTML4_DOCTYPES[text] || HTML4_DOCTYPES['transitional']
          when :xhtml
            str = XHTML_DOCTYPES[text] || XHTML_DOCTYPES['transitional']
          end
        end

        str << trailing_newlines
        [:static, str]
      end

      def on_html_comment(content)
        [:multi,
          [:static, "<!--"],
          compile(content),
          [:static, "-->"]]
      end

      def on_html_tag(name, attrs, content, closed)
        closed ||= @options[:autoclose].include?(name)
        raise "Closed tag #{name} has content" if closed && !empty_exp?(content)
        result = [:multi, [:static, "<#{name}"], compile(attrs)]
        result << [:static, " /"] if closed && xhtml?
        result << [:static, ">"] << compile(content)
        result << [:static, "</#{name}>"] if !closed
        result
      end

      def on_html_attrs(*exp)
        [:multi, *merge_and_sort_attrs(exp).map {|e| compile(e) }]
      end

      def merge_and_sort_attrs(attrs)
        result = {}
        attrs.each do |html, type, name, value|
          raise "Invalid html attribute with type [:#{html}, :#{type}]" if html != :html || type != :attr

          if result[name] && %w(class id).include?(name)
            result[name] = [:multi,
                            result[name],
                            [:static, (name == 'class' ? ' ' : '_')],
                            value]
          else
            result[name] = value
          end
        end

        result.sort.map do |name, value|
          [:html, :attr, name, value]
        end
      end

      def on_html_attr(name, value)
        [:multi,
          [:static, ' '],
          [:static, name],
          [:static, '='],
          [:static, @options[:attr_wrapper]],
          value,
          [:static, @options[:attr_wrapper]]]
      end
    end
  end
end

