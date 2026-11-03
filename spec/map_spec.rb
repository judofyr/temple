require 'spec_helper'

describe Temple::ImmutableMap do
  it 'has read accessor' do
    hash = Temple::ImmutableMap.new({a: 1},{b: 2, a: 3})
    expect(hash[:a]).to eq(1)
    expect(hash[:b]).to eq(2)
  end

  it 'has include?' do
    hash = Temple::ImmutableMap.new({a: 1},{b: 2, a: 3})
    expect(hash).to include(:a)
    expect(hash).to include(:b)
    expect(hash).not_to include(:c)
  end

  it 'has values' do
    expect(Temple::ImmutableMap.new({a: 1},{b: 2, a: 3}).values.sort).to eq([1,2])
  end

  it 'has keys' do
    expect(Temple::ImmutableMap.new({a: 1},{b: 2, a: 3}).keys).to eq([:a,:b])
  end

  it 'has to_a' do
    expect(Temple::ImmutableMap.new({a: 1},{b: 2, a: 3}).to_a).to eq([[:a, 1], [:b, 2]])
  end

  it 'converts empty maps to a hash' do
    expect(Temple::ImmutableMap.new.to_hash).to eq({})
    expect(Temple::ImmutableMap.new(nil, {}, nil).to_hash).to eq({})
  end

  it 'preserves first-map precedence and key order when converting to a hash' do
    map = Temple::ImmutableMap.new({a: nil, b: false}, {b: true, c: 3, a: 1}, {d: 4})

    expect(map.to_hash.to_a).to eq([[:a, nil], [:b, false], [:c, 3], [:d, 4]])
  end

  it 'preserves precedence and order through nested maps' do
    parent = Temple::ImmutableMap.new({a: nil}, {b: false, c: 3})
    map = Temple::ImmutableMap.new({c: 4}, parent, {a: 1, d: 5})

    expect(map.to_hash.to_a).to eq([[:c, 4], [:a, nil], [:b, false], [:d, 5]])
  end

  it 'reflects changes to underlying maps on each conversion' do
    first = {a: 1}
    second = {a: 2, b: 3}
    parent = Temple::MutableMap.new(first, second)
    map = Temple::ImmutableMap.new(parent)

    expect(map.to_hash).to eq(a: 1, b: 3)
    first.delete(:a)
    second[:b] = false
    parent[:c] = nil

    expect(map.to_hash.to_a).to eq([[:c, nil], [:a, 2], [:b, false]])
  end

  it 'returns an independent hash on each conversion' do
    source = {a: 1}.freeze
    map = Temple::ImmutableMap.new(source)
    result = map.to_hash
    result[:a] = 2
    result[:b] = 3

    expect(map.to_hash).to eq(a: 1)
    expect(map.to_hash).not_to equal(source)
    expect(map.to_hash).not_to equal(map.to_hash)
  end

  it 'does not copy hash defaults into the result' do
    source = Hash.new {|hash, key| hash[key] = :default }
    source[:a] = 1
    result = Temple::ImmutableMap.new(source).to_hash

    expect(result).to eq(a: 1)
    expect(result[:missing]).to be_nil
    expect(source).to eq(a: 1)
  end

  it 'accepts map-like inputs without each or to_hash' do
    source = Object.new
    def source.keys
      [:a, :b]
    end
    def source.include?(key)
      keys.include?(key)
    end
    def source.[](key)
      {a: 1, b: false}[key]
    end

    map = Temple::ImmutableMap.new({a: nil}, source, {c: 3})
    expect(map.to_hash.to_a).to eq([[:a, nil], [:b, false], [:c, 3]])
  end

  it 'uses map accessors rather than an input conversion method' do
    source = {a: 1}
    def source.to_hash
      {a: 2}
    end

    expect(Temple::ImmutableMap.new(source).to_hash).to eq(a: 1)
  end

  it 'preserves custom key lookup semantics' do
    map_class = Class.new(Hash) do
      def include?(key)
        super(key.to_s)
      end

      def [](key)
        super(key.to_s)
      end
    end
    source = map_class.new
    source['a'] = 1
    map = Temple::ImmutableMap.new(source, {a: 2})

    expect(map.to_hash.to_a).to eq([['a', 1], [:a, 1]])
    expect(Temple::ImmutableMap.new(map, {a: 3}).to_hash.to_a).to eq([['a', 1], [:a, 1]])
  end

  it 'only materializes values, not unset valid options' do
    parent = Temple::OptionMap.new(a: nil, b: false)
    parent.add_valid_keys(:unset)
    map = Temple::OptionMap.new(parent)

    expect(map.to_hash.to_a).to eq([[:a, nil], [:b, false]])
    expect(map.valid_key?(:unset)).to be(true)
    expect(map).not_to include(:unset)
    parent.update(a: 1)
    expect(map.to_hash.to_a).to eq([[:a, 1], [:b, false]])
  end
end

describe Temple::MutableMap do
  it 'has write accessor' do
    parent = {a: 1}
    hash = Temple::MutableMap.new(parent)
    expect(hash[:a]).to eq(1)
    hash[:a] = 2
    expect(hash[:a]).to eq(2)
    expect(parent[:a]).to eq(1)
  end
end
