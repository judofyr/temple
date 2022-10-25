require 'spec_helper'

class FilterWithDispatcherMixin
  include Temple::Mixins::Dispatcher

  def on_test(arg)
    [:on_test, arg]
  end

  def on_test_check(arg)
    [:on_check, arg]
  end

  def on_second_test(arg)
    [:on_second_test, arg]
  end

  def on_a_b(*arg)
    [:on_ab, *arg]
  end

  def on_a_b_test(arg)
    [:on_ab_test, arg]
  end

  def on_a_b_c_d_test(arg)
    [:on_abcd_test, arg]
  end
end

class FilterWithDispatcherMixinAndOn < FilterWithDispatcherMixin
  def on(*args)
    [:on_zero, *args]
  end
end

describe Temple::Mixins::Dispatcher do
  before do
    @filter = FilterWithDispatcherMixin.new
  end

  it 'should return unhandled expressions' do
    expect(@filter.call([:unhandled])).to eq([:unhandled])
  end

  it 'should dispatch first level' do
    expect(@filter.call([:test, 42])).to eq([:on_test, 42])
  end

  it 'should dispatch second level' do
    expect(@filter.call([:second, :test, 42])).to eq([:on_second_test, 42])
  end

  it 'should dispatch second level if prefixed' do
    expect(@filter.call([:test, :check, 42])).to eq([:on_check, 42])
  end

  it 'should dispatch parent level' do
    expect(@filter.call([:a, 42])).to eq [:a, 42]
    expect(@filter.call([:a, :b, 42])).to eq [:on_ab, 42]
    expect(@filter.call([:a, :b, :test, 42])).to eq [:on_ab_test, 42]
    expect(@filter.call([:a, :b, :c, 42])).to eq [:on_ab, :c, 42]
    expect(@filter.call([:a, :b, :c, :d, 42])).to eq [:on_ab, :c, :d, 42]
    expect(@filter.call([:a, :b, :c, :d, :test, 42])).to eq [:on_abcd_test, 42]
  end

  it 'should dispatch zero level' do
    expect(FilterWithDispatcherMixinAndOn.new.call([:foo,42])).to eq [:on_zero, :foo, 42]
  end
end
