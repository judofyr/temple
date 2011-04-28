require 'helper'

class TestFilter
  include Temple::Mixins::Dispatcher

  temple_dispatch :second

  def on_test(arg)
    [:on_test, arg]
  end

  def on_second_test(arg)
    [:on_second_test, arg]
  end
end

describe Temple::Mixins::Dispatcher do
  before do
    @filter = TestFilter.new
  end

  it 'should return unhandled expressions' do
    @filter.compile([:unhandled]).should.equal [:unhandled]
  end

  it 'should dispatch first level' do
    @filter.compile([:test, 42]).should.equal [:on_test, 42]
  end

  it 'should dispatch second level' do
    @filter.compile([:second, :test, 42]).should.equal [:on_second_test, 42]
  end
end
