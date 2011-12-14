require 'helper'

describe Temple::ImmutableHash do
  it 'has read accessor' do
    hash = Temple::ImmutableHash.new({:a => 1},{:b => 2, :a => 3})
    hash[:a].should.equal 1
    hash[:b].should.equal 2
  end

  it 'has include?' do
    hash = Temple::ImmutableHash.new({:a => 1},{:b => 2, :a => 3})
    hash.should.include :a
    hash.should.include :b
    hash.should.not.include :c
  end

  it 'has values' do
    Temple::ImmutableHash.new({:a => 1},{:b => 2, :a => 3}).values.sort.should.equal [1,2]
  end

  it 'has keys' do
    Temple::ImmutableHash.new({:a => 1},{:b => 2, :a => 3}).keys.should.equal [:a,:b]
  end

  it 'has to_a' do
    Temple::ImmutableHash.new({:a => 1},{:b => 2, :a => 3}).to_a.should.equal [[:a, 1], [:b, 2]]
  end
end

describe Temple::MutableHash do
  it 'has write accessor' do
    parent = {:a => 1}
    hash = Temple::MutableHash.new(parent)
    hash[:a].should.equal 1
    hash[:a] = 2
    hash[:a].should.equal 2
    parent[:a].should.equal 1
  end
end


describe Temple::SortedHash do
  before do
    @hash = Temple::SortedHash.new
    @hash['a'] = 1
    @hash['c'] = 2
    @hash['d'] = 3
    @hash['b'] = 4
    @hash['a'] = 5
  end

  it 'has read accessor' do
    @hash['a'].should.equal 5
    @hash['b'].should.equal 4
  end

  it 'has include?' do
    @hash.should.include     'a'
    @hash.should.include     'd'
    @hash.should.not.include 'e'
  end

  it 'sorts its keys' do
    @hash.keys.should.equal %w[a b c d]
  end

  it 'sorts its values by key' do
    @hash.values.should.equal [5, 4, 2, 3]
  end

  it 'sorts its items by key' do
    items = []
    @hash.each {|k, v| items << [k, v] }
    items.should.equal [['a', 5], ['b', 4], ['c', 2], ['d', 3]]
  end
end


describe Temple::OrderedHash do
  before do
    @hash = Temple::OrderedHash.new
    @hash['a'] = 1
    @hash['c'] = 2
    @hash['d'] = 3
    @hash['b'] = 4
    @hash['a'] = 5
  end

  it 'has read accessor' do
    @hash['a'].should.equal 5
    @hash['b'].should.equal 4
  end

  it 'has include?' do
    @hash.should.include     'a'
    @hash.should.include     'd'
    @hash.should.not.include 'e'
  end

  it 'preserves insertion order of keys' do
    @hash.keys.should.equal %w[a c d b]
  end

  it 'preserves insertion order of values' do
    @hash.values.should.equal [5, 2, 3, 4]
  end

  it 'preserves insertion order of items' do
    items = []
    @hash.each {|k, v| items << [k, v] }
    items.should.equal [['a', 5], ['c', 2], ['d', 3], ['b', 4]]
  end
end
