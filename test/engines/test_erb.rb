require 'engines/erb_helper'

describe Temple::Engines::ERB do
  it 'should rock or suck' do
    ::ERB.should.equal NormalERB
    TempleERB.rock!
    ::ERB.should.equal TempleERB
    TempleERB.suck!
    ::ERB.should.equal NormalERB
  end

  it 'should support generator option' do
    gen = Temple::Generators::StringBuffer
    erb = TempleERB.new("Hello", nil, nil, 'foo', :generator => gen)
    erb.src.should.match /foo = ''/

    erb = TempleERB.new("Hello", nil, nil, 'foo', :generator => gen.new(:buffer => "bar"))
    erb.src.should.match /bar = ''/
    erb.src.should.match /bar/
  end

  it 'should use optimizers' do
    obj = Object.new
    def obj.compile(exp)
      [:static, "Hello World!"]
    end

    begin
      TempleERB::Optimizers << obj
      TempleERB.new("Hello").result.should.equal "Hello World!"
    ensure
      TempleERB::Optimizers.delete(obj)
    end
  end

  it 'should raise errors without file name' do
    erb = TempleERB.new("<% raise ::ERBTestError %>")
    lambda {
      erb.result
    }.should.raise(ERBTestError).backtrace[0].should.match /\A\(erb\):1\b/
  end

  it 'should raise errors with file name' do
    erb = TempleERB.new("<% raise ::ERBTestError %>")
    erb.filename = "test filename"
    lambda {
      erb.result
    }.should.raise(ERBTestError).backtrace[0].should.match /\Atest filename:1\b/
  end

  it 'should support safe level' do
    erb = TempleERB.new("<% raise ::ERBTestError %>", 1)
    lambda {
      erb.result
    }.should.raise(ERBTestError).backtrace[0].should.match /\A\(erb\):1\b/
  end

  it 'should support safe level and file name' do
    erb = TempleERB.new("<% raise ::ERBTestError %>", 1)
    erb.filename = "test filename"
    lambda {
      erb.result
    }.should.raise(ERBTestError).backtrace[0].should.match /\Atest filename:1\b/
  end
end
