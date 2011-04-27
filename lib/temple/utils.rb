module Temple
  module Utils
    extend self

    class ImmutableHash
      include Enumerable

      def initialize(*hash)
        @hash = hash.compact
      end

      def include?(key)
        @hash.any? {|h| h.include?(key) }
      end

      def [](key)
        @hash.each {|h| return h[key] if h.include?(key) }
        nil
      end

      def each
        keys.each {|k| yield(k, self[k]) }
      end

      def keys
        @hash.inject([]) {|keys, h| keys += h.keys }.uniq
      end

      def values
        keys.map {|k| self[k] }
      end
    end

    class MutableHash < ImmutableHash
      def initialize(*hash)
        super({}, *hash)
      end

      def []=(key, value)
        @hash.first[key] = value
      end

      def update(hash)
        @hash.first.update(hash)
      end
    end

    # Returns an escaped copy of `html`.
    # Strings which are declared as html_safe are not escaped.
    #
    # @param html [String] The string to escape
    # @return [String] The escaped string
    # @api public
    def escape_html_safe(html)
      html.html_safe? ? html : escape_html(html)
    end

    if defined?(EscapeUtils)
      # Returns an escaped copy of `html`.
      #
      # @param html [String] The string to escape
      # @return [String] The escaped string
      # @api public
      def escape_html(html)
        EscapeUtils.escape_html(html.to_s)
      end
    elsif RUBY_VERSION > '1.9'
      # Used by escape_html
      # @api private
      ESCAPE_HTML = {
        '&' => '&amp;',
        '"' => '&quot;',
        '<' => '&lt;',
        '>' => '&gt;',
        '/' => '&#47;',
      }.freeze

      # Returns an escaped copy of `html`.
      #
      # @param html [String] The string to escape
      # @return [String] The escaped string
      # @api public
      def escape_html(html)
        html.to_s.gsub(/[&\"<>\/]/, ESCAPE_HTML)
      end
    else
      # Returns an escaped copy of `html`.
      #
      # @param html [String] The string to escape
      # @return [String] The escaped string
      # @api public
      def escape_html(html)
        html.to_s.gsub(/&/n, '&amp;').gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;').gsub(/\//, '&#47;')
      end
    end

    # Generate unique variable name
    #
    # @return [String] Variable name
    def unique_name(prefix = nil)
      @unique_name ||= 0
      prefix ||= (@unique_prefix ||= self.class.name.gsub('::', '_').downcase)
      "_#{prefix}#{@unique_name += 1}"
    end

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
