module Temple
  module HTML
    class Fast < Filter
      temple_dispatch :html

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
                          :id_delimiter => '_'

      def initialize(options = {})
        super
        # html5 is now called html only
        @options[:format] = :html5 if @options[:format] == :html
        unless [:xhtml, :html4, :html5].include?(@options[:format])
          raise "Invalid format #{@options[:format].inspect}"
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
        closed ||= options[:autoclose].include?(name)
        raise "Closed tag #{name} has content" if closed && !empty_exp?(content)
        result = [:multi, [:static, "<#{name}"], compile(attrs)]
        result << [:static, ' /'] if closed && xhtml?
        result << [:static, '>'] << compile(content)
        result << [:static, "</#{name}>"] if !closed
        result
      end

      def on_html_staticattrs(*attrs)
        result = {}
        attrs.each do |name, value|
          if result[name] && %w(class id).include?(name)
            raise 'Multiple id attributes specified, but id concatenation disabled' if name == 'id' && !options[:id_delimiter]
            result[name] = [:multi,
                            result[name],
                            [:static, (name == 'class' ? ' ' : options[:id_delimiter])],
                            value]
          else
            result[name] = value
          end
        end
        result.sort.inject([:multi]) do |list, (name, value)|
          list << compile_attribute(name, value)
        end
      end

      protected

      def compile_attribute(name, value)
        if empty_exp?(value)
          [:multi]
        elsif contains_static?(value)
          attribute(name, value)
        else
          tmp = tmp_var(:htmlattr)
          [:multi,
           [:capture, tmp, value],
           [:block, "unless #{tmp}.empty?"],
             attribute(name, [:dynamic, tmp]),
           [:block, 'end']]
        end
      end

      def attribute(name, value)
        [:multi,
         [:static, ' '],
         [:static, name],
         [:static, '='],
         [:static, options[:attr_wrapper]],
         value,
         [:static, options[:attr_wrapper]]]
      end

      def contains_static?(exp)
        case exp[0]
        when :multi
          exp[1..-1].any? {|e| contains_static?(e) }
        when :static
          true
        else
          false
        end
      end
    end
  end
end
