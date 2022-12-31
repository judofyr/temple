require 'spec_helper'

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

  def on_code(s)
    "C:#{s}"
  end
end

describe Temple::Generator do
  it 'should compile simple expressions' do
    gen = SimpleGenerator.new

    expect(gen.call([:static,  'test'])).to eq('_buf = BUFFER; _buf << (S:test); _buf')
    expect(gen.call([:dynamic, 'test'])).to eq('_buf = BUFFER; _buf << (D:test); _buf')
    expect(gen.call([:code,    'test'])).to eq('_buf = BUFFER; C:test; _buf')
  end

  it 'should compile multi expression' do
    gen = SimpleGenerator.new(buffer: "VAR")
    expect(gen.call([:multi,
      [:static, "static"],
      [:dynamic, "dynamic"],
      [:code, "code"]
    ])).to eq('VAR = BUFFER; VAR << (S:static); VAR << (D:dynamic); C:code; VAR')
  end

  it 'should compile capture' do
    gen = SimpleGenerator.new(buffer: "VAR", capture_generator: SimpleGenerator)
    expect(gen.call([:capture, "foo",
      [:static, "test"]
    ])).to eq('VAR = BUFFER; foo = BUFFER; foo << (S:test); foo; VAR')
  end

  it 'should compile capture with multi' do
    gen = SimpleGenerator.new(buffer: "VAR", capture_generator: SimpleGenerator)
    expect(gen.call([:multi,
      [:static, "before"],

      [:capture, "foo", [:multi,
        [:static, "static"],
        [:dynamic, "dynamic"],
        [:code, "code"]]],

      [:static, "after"]
    ])).to eq('VAR = BUFFER; VAR << (S:before); foo = BUFFER; foo << (S:static); ' +
      'foo << (D:dynamic); C:code; foo; VAR << (S:after); VAR')
  end

  it 'should compile newlines' do
    gen = SimpleGenerator.new(buffer: "VAR")
    expect(gen.call([:multi,
      [:static, "static"],
      [:newline],
      [:dynamic, "dynamic"],
      [:newline],
      [:code, "code"]
    ])).to eq("VAR = BUFFER; VAR << (S:static); \n; " +
      "VAR << (D:dynamic); \n; C:code; VAR")
  end
end

describe Temple::Generators::Array do
  it 'should compile simple expressions' do
    gen = Temple::Generators::Array.new(freeze_static: false)
    expect(gen.call([:static,  'test'])).to eq('_buf = []; _buf << ("test"); _buf')
    expect(gen.call([:dynamic, 'test'])).to eq('_buf = []; _buf << (test); _buf')
    expect(gen.call([:code,    'test'])).to eq('_buf = []; test; _buf')

    expect(gen.call([:multi, [:static, 'a'], [:static,  'b']])).to eq('_buf = []; _buf << ("a"); _buf << ("b"); _buf')
    expect(gen.call([:multi, [:static, 'a'], [:dynamic, 'b']])).to eq('_buf = []; _buf << ("a"); _buf << (b); _buf')
  end

  it 'should freeze static' do
    gen = Temple::Generators::Array.new(freeze_static: true)
    expect(gen.call([:static,  'test'])).to eq('_buf = []; _buf << ("test".freeze); _buf')
  end
end

describe Temple::Generators::ArrayBuffer do
  it 'should compile simple expressions' do
    gen = Temple::Generators::ArrayBuffer.new(freeze_static: false)
    expect(gen.call([:static,  'test'])).to eq('_buf = "test"')
    expect(gen.call([:dynamic, 'test'])).to eq('_buf = (test).to_s')
    expect(gen.call([:code,    'test'])).to eq('_buf = []; test; _buf = _buf.join("")')

    expect(gen.call([:multi, [:static, 'a'], [:static,  'b']])).to eq('_buf = []; _buf << ("a"); _buf << ("b"); _buf = _buf.join("")')
    expect(gen.call([:multi, [:static, 'a'], [:dynamic, 'b']])).to eq('_buf = []; _buf << ("a"); _buf << (b); _buf = _buf.join("")')
  end

  it 'should freeze static' do
    gen = Temple::Generators::ArrayBuffer.new(freeze_static: true)
    expect(gen.call([:static,  'test'])).to eq('_buf = "test"')
    expect(gen.call([:multi, [:dynamic, '1'], [:static,  'test']])).to eq('_buf = []; _buf << (1); _buf << ("test".freeze); _buf = _buf.join("".freeze)')
  end
end

describe Temple::Generators::StringBuffer do
  it 'should compile simple expressions' do
    gen = Temple::Generators::StringBuffer.new(freeze_static: false)
    expect(gen.call([:static,  'test'])).to eq('_buf = "test"')
    expect(gen.call([:dynamic, 'test'])).to eq('_buf = (test).to_s')
    expect(gen.call([:code,    'test'])).to eq('_buf = \'\'; test; _buf')

    expect(gen.call([:multi, [:static, 'a'], [:static,  'b']])).to eq('_buf = \'\'; _buf << ("a"); _buf << ("b"); _buf')
    expect(gen.call([:multi, [:static, 'a'], [:dynamic, 'b']])).to eq('_buf = \'\'; _buf << ("a"); _buf << ((b).to_s); _buf')
  end

  it 'should freeze static' do
    gen = Temple::Generators::StringBuffer.new(freeze_static: true)
    expect(gen.call([:static,  'test'])).to eq('_buf = "test"')
    expect(gen.call([:multi, [:dynamic, '1'], [:static,  'test']])).to eq('_buf = \'\'; _buf << ((1).to_s); _buf << ("test".freeze); _buf')
  end
end

describe Temple::Generators::ERB do
  it 'should compile simple expressions' do
    gen = Temple::Generators::ERB.new
    expect(gen.call([:static,  'test'])).to eq('test')
    expect(gen.call([:dynamic, 'test'])).to eq('<%= test %>')
    expect(gen.call([:code,    'test'])).to eq('<% test %>')

    expect(gen.call([:multi, [:static, 'a'], [:static,  'b']])).to eq('ab')
    expect(gen.call([:multi, [:static, 'a'], [:dynamic, 'b']])).to eq('a<%= b %>')
  end
end

describe Temple::Generators::RailsOutputBuffer do
  it 'should compile simple expressions' do
    gen = Temple::Generators::RailsOutputBuffer.new(freeze_static: false)
    expect(gen.call([:static,  'test'])).to eq('@output_buffer = output_buffer || ActionView::OutputBuffer.new; ' +
      '@output_buffer.safe_concat(("test")); @output_buffer')
    expect(gen.call([:dynamic, 'test'])).to eq('@output_buffer = output_buffer || ActionView::OutputBuffer.new; ' +
      '@output_buffer.safe_concat(((test).to_s)); @output_buffer')
    expect(gen.call([:code,    'test'])).to eq('@output_buffer = output_buffer || ActionView::OutputBuffer.new; ' +
      'test; @output_buffer')
  end

  it 'should freeze static' do
    gen = Temple::Generators::RailsOutputBuffer.new(freeze_static: true)
    expect(gen.call([:static,  'test'])).to eq('@output_buffer = output_buffer || ActionView::OutputBuffer.new; @output_buffer.safe_concat(("test".freeze)); @output_buffer')
  end
end
