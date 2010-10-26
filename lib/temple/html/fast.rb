module Temple
  module HTML
    class Fast
      DEFAULT_OPTIONS = {
        :format => :xhtml,
        :attr_wrapper => "'",
        :autoclose => %w[meta img link br hr input area param col base]
      }

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.merge(options)

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

      def compile(exp)
        case exp[0]
        when :multi, :capture
          send("on_#{exp[0]}", *exp[1..-1])
        when :html
          send("on_#{exp[1]}", *exp[2..-1])
        else
          exp
        end
      end

      def on_multi(*exp)
        [:multi, *exp.map { |e| compile(e) }]
      end

      def on_capture(name, exp)
        [:capture, name, compile(exp)]
      end

      def on_doctype(type)
        trailing_newlines = type[/(\A|[^\r])(\n+)\Z/, 2].to_s

        text = type.to_s.downcase.strip
        if text.index("xml") == 0
          if html?
            return [:multi].concat([[:newline]] * trailing_newlines.size)
          end

          wrapper = @options[:attr_wrapper]
          str = "<?xml version=#{wrapper}1.0#{wrapper} encoding=#{wrapper}#{text.split(' ')[1] || "utf-8"}#{wrapper} ?>"
        end

        str = "<!DOCTYPE html>" if html5?

        str ||= if xhtml?
          case text
          when /^1\.1/;     '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
          when /^5/;        '<!DOCTYPE html>'
          when "strict";    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
          when "frameset";  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
          when "mobile";    '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
          when "basic";     '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
          else              '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
          end
        elsif html4?
          case text
            when "strict";    '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
            when "frameset";  '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'
            else              '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
          end
        end

        str << trailing_newlines
        [:static, str]
      end

      def on_comment(content)
        [:multi,
          [:static, "<!--"],
          compile(content),
          [:static, "-->"]]
      end

      def on_tag(name, attrs, content)
        ac = @options[:autoclose].include?(name)
        result = [:multi]
        result << [:static, "<#{name}"]
        result << compile(attrs)
        result << [:static, " /"] if ac && xhtml?
        result << [:static, ">"]
        result << compile(content)
        result << [:static, "</#{name}>"] if !ac
        result
      end

      def on_attrs(*exp)
        if exp.all? { |e| attr_easily_compilable?(e) }
          [:multi, *merge_basicattrs(exp).map { |e| compile(e) }]
        else
          raise "[:html, :attrs] currently only support basicattrs"
        end
      end

      def attr_easily_compilable?(exp)
        exp[1] == :basicattr and
        exp[2][0] == :static
      end

      def merge_basicattrs(attrs)
        result = []
        position = {}

        attrs.each do |(html, type, (name_type, name), value)|
          if pos = position[name]
            case name
            when 'class', 'id'
              value = [:multi,
                result[pos].last,  # previous value
                [:static, (name == 'class' ? ' ' : '_')], # delimiter
                value]             # new value
            end

            result[pos] = [name, value]
          else
            position[name] = result.size
            result << [name, value]
          end
        end

        final = []
        result.each_with_index do |(name, value), index|
          final << [:html, :basicattr, [:static, name], value]
        end
        final
      end

      def on_basicattr(name, value)
        [:multi,
          [:static, " "],
          name,
          [:static, "="],
          [:static, @options[:attr_wrapper]],
          value,
          [:static, @options[:attr_wrapper]]]
      end
    end
  end
end

