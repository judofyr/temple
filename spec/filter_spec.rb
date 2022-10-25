require 'spec_helper'

class SimpleFilter < Temple::Filter
  define_options :key

  def on_test(arg)
    [:on_test, arg]
  end
end

describe Temple::Filter do
  it 'should support options' do
    expect(Temple::Filter).to respond_to(:default_options)
    expect(Temple::Filter).to respond_to(:set_default_options)
    expect(Temple::Filter).to respond_to(:define_options)
    expect(Temple::Filter.new.options).to be_a(Temple::ImmutableMap)
    expect(SimpleFilter.new(key: 3).options[:key]).to eq(3)
  end

  it 'should implement call' do
    expect(Temple::Filter.new.call([:exp])).to eq([:exp])
  end

  it 'should process expressions' do
    filter = SimpleFilter.new
    expect(filter.call([:unhandled])).to eq([:unhandled])
    expect(filter.call([:test, 42])).to eq([:on_test, 42])
  end
end
