module Temple
  # Immutable hash class which supports hash merging
  # @api public
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

  # Mutable hash class which supports hash merging
  # @api public
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

  class HashBase
    include Enumerable

    def initialize
      @hash = {}
    end

    def include?(key)
      @hash.include?(key)
    end

    def [](key)
      @hash[key]
    end

    def each
      keys.each {|k| yield k, @hash[k] }
    end

    def values
      keys.map {|k| @hash[k] }
    end
  end

  # Hash class where the items are sorted by key
  # @api public
  class SortedHash < HashBase
    def []=(key, value)
      @hash[key] = value
    end

    def update(hash)
      @hash.update(hash)
    end

    def keys
      @hash.keys.sort
    end
  end

  # Hash class where the insertion order is preserved (like in Ruby 1.9)
  if RUBY_VERSION > '1.9'
    OrderedHash = Hash
  else # Ruby 1.8.x
    class OrderedHash < HashBase
      def initialize
        super
        @keys = []
      end

      def []=(key, value)
        @keys << key unless include?(key)
        @hash[key] = value
      end

      def update(hash)
        @keys += hash.keys - @keys
        @hash.update(hash)
      end

      def keys
        @keys
      end
    end
  end
end
