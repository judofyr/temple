module Temple
  module HTML
    class Fast < Filter
      XHTML_DOCTYPES = {
        '1.1'          => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
        '5'            => '<!DOCTYPE html>',
        'html'         => '<!DOCTYPE html>',
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
                          :autoclose => %w[meta img link br hr input area param col base],
                          :attr_delimiter => {'id' => '_', 'class' => ' '}

      def initialize(opts = {})
        super
        # html5 is now called html only
        options[:format] = :html5 if options[:format] == :html
        unless [:xhtml, :html4, :html5].include?(options[:format])
          raise "Invalid format #{options[:format].inspect}"
        end
      end

      def xhtml?
        options[:format] == :xhtml
      end

      def html?
        options[:format] == :html5 || options[:format] == :html4
      end

      def on_html_doctype(type)
        type = type.to_s
        trailing_newlines = type[/(\A|[^\r])(\n+)\Z/, 2].to_s
        text = type.downcase.strip

        if text =~ /^xml/
          raise 'Invalid xml directive in html mode' if html?
          wrapper = options[:attr_wrapper]
          str = "<?xml version=#{wrapper}1.0#{wrapper} encoding=#{wrapper}#{text.split(' ')[1] || "utf-8"}#{wrapper} ?>"
        else
          case options[:format]
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
          [:static, '<!--'],
          compile(content),
          [:static, '-->']]
      end

      def on_html_tag(name, attrs, closed, content)
        name = name.to_s
        closed ||= options[:autoclose].include?(name)
        raise(InvalidExpression, "Closed tag #{name} has content") if closed && !empty_exp?(content)
        result = [:multi, [:static, "<#{name}"], compile(attrs)]
        result << [:static, (closed && xhtml? ? ' /' : '') + '>'] << compile(content)
        result << [:static, "</#{name}>"] if !closed
        result
      end

      def on_html_attrs(*attrs)
        result = {}
        attrs.each do |attr|
          raise(InvalidExpression, 'Attribute is not a html attr') if attr[0] != :html || attr[1] != :attr
          name, value = attr[2].to_s, attr[3]
          next if empty_exp?(value)
          if result[name]
            delimiter = options[:attr_delimiter][name]
            raise "Multiple #{name} attributes specified" unless delimiter
            if contains_static?(value)
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
          end
        end
        [:multi, *result.sort.map {|name,attr| compile(attr) }]
      end

      def on_html_attr(name, value)
        if empty_exp?(value)
          compile(value)
        elsif contains_static?(value)
          attribute(name, value)
        else
          tmp = unique_name
          [:multi,
           [:capture, tmp, compile(value)],
           [:if, "!#{tmp}.empty?",
            attribute(name, [:dynamic, tmp])]]
        end
      end

      protected

      def attribute(name, value)
        [:multi,
         [:static, " #{name}=#{options[:attr_wrapper]}"],
         compile(value),
         [:static, options[:attr_wrapper]]]
      end

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
