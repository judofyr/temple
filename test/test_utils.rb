require 'helper'

class UniqueTest
  include Temple::Utils
end

describe Temple::Utils do
  it 'has empty_exp?' do
    Temple::Utils.empty_exp?([:multi]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi]]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi, [:newline]], [:newline]]).should.be.true
    Temple::Utils.empty_exp?([:multi]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi, [:static, 'text']]]).should.be.false
    Temple::Utils.empty_exp?([:multi, [:newline], [:multi, [:dynamic, 'text']]]).should.be.false
  end

  it 'has unique_name' do
    u = UniqueTest.new
    u.unique_name.should.equal '_uniquetest1'
    u.unique_name.should.equal '_uniquetest2'
    UniqueTest.new.unique_name.should.equal '_uniquetest1'
  end

  it 'has escape_html' do
    Temple::Utils.escape_html('<').should.equal '&lt;'
  end

  it 'should escape unsafe html strings' do
    with_html_safe(false) do
      Temple::Utils.escape_html_safe('<').should.equal '&lt;'
    end
  end

  it 'should not escape safe html strings' do
    with_html_safe(true) do
      Temple::Utils.escape_html_safe('<').should.equal '<'
    end
  end
end

describe Temple::Utils::ImmutableHash do
  it 'has read accessor' do
    hash = Temple::Utils::ImmutableHash.new({:a => 1},{:b => 2, :a => 3})
    hash[:a].should.equal 1
    hash[:b].should.equal 2
  end

  it 'has include?' do
    hash = Temple::Utils::ImmutableHash.new({:a => 1},{:b => 2, :a => 3})
    hash.should.include :a
    hash.should.include :b
    hash.should.not.include :c
  end

  it 'has values' do
    Temple::Utils::ImmutableHash.new({:a => 1},{:b => 2, :a => 3}).values.sort.should.equal [1,2]
  end

  it 'has keys' do
    Temple::Utils::ImmutableHash.new({:a => 1},{:b => 2, :a => 3}).keys.should.equal [:a,:b]
  end

  it 'has to_a' do
    Temple::Utils::ImmutableHash.new({:a => 1},{:b => 2, :a => 3}).to_a.should.equal [[:a, 1], [:b, 2]]
  end
end

describe Temple::Utils::MutableHash do
  it 'has write accessor' do
    parent = {:a => 1}
    hash = Temple::Utils::MutableHash.new(parent)
    hash[:a].should.equal 1
    hash[:a] = 2
    hash[:a].should.equal 2
    parent[:a].should.equal 1
  end
end
