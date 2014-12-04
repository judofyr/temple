require 'helper'

describe Temple::Filters::StaticFreezer do
  if RUBY_VERSION >= '2.1'
    it 'should freeze static on new ruby' do
      filter = Temple::Filters::StaticFreezer.new
      filter.call([:static, 'hi']).should.equal [:dynamic, '"hi".freeze']
    end
  else
    it 'should not freeze static on old ruby' do
      filter = Temple::Filters::StaticFreezer.new
      filter.call([:static, 'hi']).should.equal [:static, 'hi']
    end
  end

  it 'should freeze static if free_static==true' do
    filter = Temple::Filters::StaticFreezer.new(freeze_static: true)
    filter.call([:static, 'hi']).should.equal [:dynamic, '"hi".freeze']
  end

  it 'should not freeze static if free_static==false' do
    filter = Temple::Filters::StaticFreezer.new(freeze_static: false)
    filter.call([:static, 'hi']).should.equal [:static, 'hi']
  end
end
