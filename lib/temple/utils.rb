begin
  require 'escape_utils'
rescue LoadError
  # Loading EscapeUtils failed
end

module Temple
  # @api public
  module Utils
    extend self

    if defined?(EscapeUtils)
      # Returns an escaped copy of `html`.
      #
      # @param html [String] The string to escape
      # @return [String] The escaped string
      def escape_html(html)
        EscapeUtils.escape_html(html.to_s, false)
      end
    else
      # Used by escape_html
      # @api private
      ESCAPE_HTML = {
        '&'  => '&amp;',
        '"'  => '&quot;',
        '\'' => '&#39;',
        '<'  => '&lt;',
        '>'  => '&gt;'
      }.freeze

      if //.respond_to?(:encoding)
        ESCAPE_HTML_PATTERN = Regexp.union(*ESCAPE_HTML.keys)
      else
        # On 1.8, there is a kcode = 'u' bug that allows for XSS otherwise
        # TODO doesn't apply to jruby, so a better condition above might be preferable?
        ESCAPE_HTML_PATTERN = /#{Regexp.union(*ESCAPE_HTML.keys)}/n
      end

      if RUBY_VERSION > '1.9'
        # Returns an escaped copy of `html`.
        #
        # @param html [String] The string to escape
        # @return [String] The escaped string
        def escape_html(html)
          html.to_s.gsub(ESCAPE_HTML_PATTERN, ESCAPE_HTML)
        end
      else
        # Returns an escaped copy of `html`.
        #
        # @param html [String] The string to escape
        # @return [String] The escaped string
        def escape_html(html)
          html.to_s.gsub(ESCAPE_HTML_PATTERN) {|c| ESCAPE_HTML[c] }
        end
      end
    end

    # Returns an escaped copy of `html`.
    # Strings which are declared as html_safe are not escaped.
    #
    # @note You should prefer {escape_html_safe}, which is a safe alias that can be
    #   used both in systems that support and don't support SafeBuffer strings.
    #
    # @param html [String] The string to escape
    # @return [String] The escaped string
    def escape_html_unless_safe(html)
      html.html_safe? ? html : escape_html(html)
    end

    # @!method escape_html_safe(html)
    # @overload escape_html_safe(html)
    #   When system supports SafeBuffer string, it's an alias to #escape_html_unless_safe.
    #   @see escape_html_unless_safe
    # @overload escape_html_safe(html)
    #   When system doesn't support SafeBuffer string, it's an alias to #escape_html.
    #   @see escape_html
    if "".respond_to?(:html_safe?)
      alias_method :escape_html_safe, :escape_html_unless_safe
    else
      alias_method :escape_html_safe, :escape_html
    end

    # Generate unique variable name
    #
    # @param prefix [String] Variable name prefix
    # @return [String] Variable name
    def unique_name(prefix = nil)
      @unique_name ||= 0
      prefix ||= (@unique_prefix ||= self.class.name.gsub('::', '_').downcase)
      "_#{prefix}#{@unique_name += 1}"
    end

    # Check if expression is empty
    #
    # @param exp [Array] Temple expression
    # @return true if expression is empty
    def empty_exp?(exp)
      case exp[0]
      when :multi
        exp[1..-1].all? {|e| empty_exp?(e) }
      when :newline
        true
      else
        false
      end
    end
  end
end
