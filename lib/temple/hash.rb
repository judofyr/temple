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

    def only(*filter)
      result = {}
      filter = filter.flatten
      each do |k,v|
        result[k] = v if filter.include?(k)
      end
      result
    end

    def without(*filter)
      result = {}
      filter = filter.flatten
      each do |k,v|
        result[k] = v unless filter.include?(k)
      end
      result
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

  class OptionHash < MutableHash
    def initialize(*hash, &block)
      super(*hash)
      @invalid = block
      @valid = {}
    end

    def []=(key, value)
      validate_key!(key)
      super
    end

    def update(hash)
      validate_hash!(hash)
      super
    end

    def valid_keys
      keys.concat(@valid.keys).uniq
    end

    def add(*keys)
      keys.flatten.each { |key| @valid[key] = true }
    end

    def validate_hash!(hash)
      hash.keys.each {|key| validate_key!(key) }
    end

    def validate_key!(key)
      @invalid.call(self, key) unless valid_key?(key)
    end

    def valid_key?(key)
      include?(key) || @valid.include?(key) ||
        @hash.any? {|h| h.valid_key?(key) if h.respond_to?(:valid_key?) }
    end
  end
end
