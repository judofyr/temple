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
