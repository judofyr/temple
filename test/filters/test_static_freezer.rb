require 'helper'

describe Temple::Filters::StaticFreezer do
  before do
    @filter = Temple::Filters::StaticFreezer.new
  end

  it 'should freeze static' do
    @filter.call([:static, 'hi']).should.equal [:dynamic, '"hi".freeze']
  end
end
