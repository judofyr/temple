# frozen_string_literal: true
module Temple
  # Immutable map class which supports map merging
  # @api public
  class ImmutableMap
    include Enumerable

    def initialize(*map)
      @map = map.compact
    end

    def include?(key)
      @map.any? {|h| h.include?(key) }
    end

    def [](key)
      @map.each {|h| return h[key] if h.include?(key) }
      nil
    end

    def each(&block)
      to_hash.each(&block)
    end

    def keys
      to_hash.keys
    end

    def values
      to_hash.values
    end

    def to_hash
      result = {}
      @map.each {|h| result.update(h.to_hash) {|_key, existing, _| existing } }
      result
    end
  end

  # Mutable map class which supports map merging
  # @api public
  class MutableMap < ImmutableMap
    def initialize(*map)
      super({}, *map)
    end

    def []=(key, value)
      @map.first[key] = value
    end

    def update(map)
      @map.first.update(map)
    end
  end

  class OptionMap < MutableMap
    @generation = 0

    class << self
      attr_reader :generation

      # Engines check every option against every filter, so valid keys are
      # cached until any OptionMap changes (options are set once, at load time).
      def changed!
        @generation += 1
      end
    end

    def initialize(*map, &block)
      super(*map)
      @handler = block
      @valid = {}
      @deprecated = {}
    end

    def []=(key, value)
      validate_key!(key)
      OptionMap.changed!
      super
    end

    def update(map)
      validate_map!(map)
      OptionMap.changed!
      super
    end

    def valid_keys
      (keys + @valid.keys +
       @map.map {|h| h.valid_keys if h.respond_to?(:valid_keys) }.compact.flatten).uniq
    end

    def add_valid_keys(*keys)
      keys.flatten.each { |key| @valid[key] = true }
      OptionMap.changed!
    end

    def add_deprecated_keys(*keys)
      keys.flatten.each { |key| @valid[key] = @deprecated[key] = true }
      OptionMap.changed!
    end

    def validate_map!(map)
      map.to_hash.keys.each {|key| validate_key!(key) }
    end

    def validate_key!(key)
      @handler.call(self, key, :deprecated) if deprecated_key?(key)
      @handler.call(self, key, :invalid) unless valid_key?(key)
    end

    def deprecated_key?(key)
      @deprecated.include?(key) ||
        @map.any? {|h| h.deprecated_key?(key) if h.respond_to?(:deprecated_key?) }
    end

    def valid_key?(key)
      generation = OptionMap.generation
      unless @cached_valid_keys_generation == generation
        @cached_valid_keys = Hash[valid_keys.map {|k| [k, true] }]
        @cached_valid_keys_generation = generation
      end
      @cached_valid_keys.include?(key)
    end
  end
end
