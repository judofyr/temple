require 'helper'

class SimpleGenerator < Temple::Generator
  def preamble
    "#{buffer} = BUFFER"
  end

  def postamble
    buffer
  end

  def on_static(s)
    concat "S:#{s}"
  end

  def on_dynamic(s)
    concat "D:#{s}"
  end

  def on_block(s)
    "B:#{s}"
  end
end

describe Temple::Generator do
  it 'should compile simple expressions' do
    gen = SimpleGenerator.new

    gen.compile([:static, "test"]).should.match(/ << \(S:test\)/)
    gen.compile([:dynamic, "test"]).should.match(/ << \(D:test\)/)
    gen.compile([:block, "test"]).should.match(/B:test/)
  end

  it 'should compile multi expression' do
    gen = SimpleGenerator.new(:buffer => "VAR")
    str = gen.compile([:multi,
      [:static, "static"],
      [:dynamic, "dynamic"],
      [:block, "block"]
    ])

    str.should.match(/VAR = BUFFER/)
    str.should.match(/VAR << \(S:static\)/)
    str.should.match(/VAR << \(D:dynamic\)/)
    str.should.match(/ B:block /)
  end

  it 'should compile capture' do
    gen = SimpleGenerator.new(:buffer => "VAR", :capture_generator => SimpleGenerator)
    str = gen.compile([:capture, "foo", [:static, "test"]])

    str.should.match(/foo = BUFFER/)
    str.should.match(/foo << \(S:test\)/)
    str.should.match(/VAR\Z/)
  end

  it 'should compile capture with multi' do
    gen = SimpleGenerator.new(:buffer => "VAR", :capture_generator => SimpleGenerator)
    str = gen.compile([:multi,
      [:static, "before"],

      [:capture, "foo", [:multi,
        [:static, "static"],
        [:dynamic, "dynamic"],
        [:block, "block"]]],

      [:static, "after"]
    ])

    str.should.match(/VAR << \(S:before\)/)
    str.should.match(     /foo = BUFFER/)
    str.should.match(     /foo << \(S:static\)/)
    str.should.match(     /foo << \(D:dynamic\)/)
    str.should.match(     / B:block /)
    str.should.match(/VAR << \(S:after\)/)
    str.should.match(/VAR\Z/)
  end

  it 'should compile newlines' do
    gen = SimpleGenerator.new(:buffer => "VAR")
    str = gen.compile([:multi,
      [:static, "static"],
      [:newline],
      [:dynamic, "dynamic"],
      [:newline],
      [:block, "block"]
    ])

    lines = str.split("\n")
    lines[0].should.match(/VAR << \(S:static\)/)
    lines[1].should.match(/VAR << \(D:dynamic\)/)
    lines[2].should.match(/ B:block /)
  end
end
