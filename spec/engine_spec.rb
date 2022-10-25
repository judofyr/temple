# -*- coding: utf-8 -*-
require 'spec_helper'

class Callable1
  def call(exp)
    exp
  end
end

class Callable2
  def call(exp)
    exp
  end
end

class MySpecialFilter
  def initialize(opts = {})
  end

  def call(exp)
    exp
  end
end

class TestEngine < Temple::Engine
  use(:Parser) do |input|
    [:static, input]
  end
  use :MyFilter1, proc {|exp| exp }
  use :MyFilter2, proc {|exp| exp }
  use Temple::HTML::Pretty, pretty: true
  filter :MultiFlattener
  generator :ArrayBuffer
  use(:BeforeBeforeLast) { MySpecialFilter }
  use :BeforeLast, Callable1.new
  use(:Last) { Callable2.new }
end

describe Temple::Engine do
  it 'should build chain' do
    expect(TestEngine.chain.size).to eq(9)

    expect(TestEngine.chain[0].first).to eq(:Parser)
    expect(TestEngine.chain[0].size).to eq(2)
    expect(TestEngine.chain[0].last).to be_a(Proc)

    expect(TestEngine.chain[1].first).to eq(:MyFilter1)
    expect(TestEngine.chain[1].size).to eq(2)
    expect(TestEngine.chain[1].last).to be_a(Proc)

    expect(TestEngine.chain[2].first).to eq(:MyFilter2)
    expect(TestEngine.chain[2].size).to eq(2)
    expect(TestEngine.chain[2].last).to be_a(Proc)

    expect(TestEngine.chain[3].first).to eq(:'Temple::HTML::Pretty')
    expect(TestEngine.chain[3].size).to eq(2)
    expect(TestEngine.chain[3].last).to be_a(Proc)

    expect(TestEngine.chain[4].first).to eq(:MultiFlattener)
    expect(TestEngine.chain[4].size).to eq(2)
    expect(TestEngine.chain[4].last).to be_a(Proc)

    expect(TestEngine.chain[5].first).to eq(:ArrayBuffer)
    expect(TestEngine.chain[5].size).to eq(2)
    expect(TestEngine.chain[5].last).to be_a(Proc)

    expect(TestEngine.chain[6].first).to eq(:BeforeBeforeLast)
    expect(TestEngine.chain[6].size).to eq(2)
    expect(TestEngine.chain[6].last).to be_a(Proc)

    expect(TestEngine.chain[7].first).to eq(:BeforeLast)
    expect(TestEngine.chain[7].size).to eq(2)
    expect(TestEngine.chain[7].last).to be_a(Proc)

    expect(TestEngine.chain[8].first).to eq(:Last)
    expect(TestEngine.chain[8].size).to eq(2)
    expect(TestEngine.chain[8].last).to be_a(Proc)
  end

  it 'should instantiate chain' do
    call_chain = TestEngine.new.send(:call_chain)
    expect(call_chain[0]).to be_a(Method)
    expect(call_chain[1]).to be_a(Method)
    expect(call_chain[2]).to be_a(Method)
    expect(call_chain[3]).to be_a(Temple::HTML::Pretty)
    expect(call_chain[4]).to be_a(Temple::Filters::MultiFlattener)
    expect(call_chain[5]).to be_a(Temple::Generators::ArrayBuffer)
    expect(call_chain[6]).to be_a(MySpecialFilter)
    expect(call_chain[7]).to be_a(Callable1)
    expect(call_chain[8]).to be_a(Callable2)
  end

  it 'should have #append' do
    engine = TestEngine.new
    call_chain = engine.send(:call_chain)
    expect(call_chain.size).to eq(9)

    engine.append :MyFilter3 do |exp|
      exp
    end

    expect(TestEngine.chain.size).to eq(9)
    expect(engine.chain.size).to eq(10)
    expect(engine.chain[9].first).to eq(:MyFilter3)
    expect(engine.chain[9].size).to eq(2)
    expect(engine.chain[9].last).to be_a(Proc)

    call_chain = engine.send(:call_chain)
    expect(call_chain.size).to eq(10)
    expect(call_chain[9]).to be_a(Method)
  end

  it 'should have #prepend' do
    engine = TestEngine.new
    call_chain = engine.send(:call_chain)
    expect(call_chain.size).to eq(9)

    engine.prepend :MyFilter0 do |exp|
      exp
    end

    expect(TestEngine.chain.size).to eq(9)
    expect(engine.chain.size).to eq(10)
    expect(engine.chain[0].first).to eq(:MyFilter0)
    expect(engine.chain[0].size).to eq(2)
    expect(engine.chain[0].last).to be_a(Proc)
    expect(engine.chain[1].first).to eq(:Parser)

    call_chain = engine.send(:call_chain)
    expect(call_chain.size).to eq(10)
    expect(call_chain[0]).to be_a(Method)
  end

  it 'should have #after' do
    engine = TestEngine.new
    engine.after :Parser, :MyFilter0 do |exp|
      exp
    end
    expect(TestEngine.chain.size).to eq(9)
    expect(engine.chain.size).to eq(10)
    expect(engine.chain[0].first).to eq(:Parser)
    expect(engine.chain[1].first).to eq(:MyFilter0)
    expect(engine.chain[2].first).to eq(:MyFilter1)
  end

  it 'should have #before' do
    engine = TestEngine.new
    engine.before :MyFilter1, :MyFilter0 do |exp|
      exp
    end
    expect(TestEngine.chain.size).to eq(9)
    expect(engine.chain.size).to eq(10)
    expect(engine.chain[0].first).to eq(:Parser)
    expect(engine.chain[1].first).to eq(:MyFilter0)
    expect(engine.chain[2].first).to eq(:MyFilter1)
  end

  it 'should have #remove' do
    engine = TestEngine.new
    engine.remove :MyFilter1
    expect(TestEngine.chain.size).to eq(9)
    expect(engine.chain.size).to eq(8)
    expect(engine.chain[0].first).to eq(:Parser)
    expect(engine.chain[1].first).to eq(:MyFilter2)

    engine = TestEngine.new
    engine.remove /Last/
    expect(engine.chain.size).to eq(6)
  end

  it 'should have #replace' do
    engine = TestEngine.new
    engine.replace :Parser, :MyParser do |exp|
      exp
    end
    expect(engine.chain.size).to eq(9)
    expect(engine.chain[0].first).to eq(:MyParser)
  end

  it 'should work with inheritance' do
    inherited_engine = Class.new(TestEngine)
    expect(inherited_engine.chain.size).to eq(9)
    inherited_engine.append :MyFilter3 do |exp|
      exp
    end
    expect(inherited_engine.chain.size).to eq(10)
    expect(TestEngine.chain.size).to eq(9)
  end
end
