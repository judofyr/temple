require 'spec_helper'

describe Temple::Filters::DynamicInliner do
  before do
    @filter = Temple::Filters::DynamicInliner.new
  end

  it 'should compile several statics into dynamic' do
    expect(@filter.call([:multi,
      [:static, "Hello "],
      [:static, "World\n "],
      [:static, "Have a nice day"]
    ])).to eq [:dynamic, '"Hello World\n Have a nice day"']
  end

  it 'should compile several dynamics into dynamic' do
    expect(@filter.call([:multi,
      [:dynamic, "@hello"],
      [:dynamic, "@world"],
      [:dynamic, "@yeah"]
    ])).to eq [:dynamic, '"#{@hello}#{@world}#{@yeah}"']
  end

  it 'should compile static and dynamic into dynamic' do
    expect(@filter.call([:multi,
      [:static, "Hello"],
      [:dynamic, "@world"],
      [:dynamic, "@yeah"],
      [:static, "Nice"]
    ])).to eq [:dynamic, '"Hello#{@world}#{@yeah}Nice"']
  end

  it 'should merge statics and dynamics around a code' do
    expect(@filter.call([:multi,
      [:static, "Hello "],
      [:dynamic, "@world"],
      [:code, "Oh yeah"],
      [:dynamic, "@yeah"],
      [:static, "Once more"]
    ])).to eq [:multi,
      [:dynamic, '"Hello #{@world}"'],
      [:code, "Oh yeah"],
      [:dynamic, '"#{@yeah}Once more"']
    ]
  end

  it 'should keep codes intact' do
    expect(@filter.call([:multi, [:code, 'foo']])).to eq([:code, 'foo'])
  end

  it 'should keep single statics intact' do
    expect(@filter.call([:multi, [:static, 'foo']])).to eq([:static, 'foo'])
  end

  it 'should keep single dynamic intact' do
    expect(@filter.call([:multi, [:dynamic, 'foo']])).to eq([:dynamic, 'foo'])
  end

  it 'should inline inside multi' do
    expect(@filter.call([:multi,
      [:static, "Hello "],
      [:dynamic, "@world"],
      [:multi,
        [:static, "Hello "],
        [:dynamic, "@world"]],
      [:static, "Hello "],
      [:dynamic, "@world"]
    ])).to eq [:multi,
      [:dynamic, '"Hello #{@world}"'],
      [:dynamic, '"Hello #{@world}"'],
      [:dynamic, '"Hello #{@world}"']
    ]
  end

  it 'should merge across newlines' do
    exp = expect(@filter.call([:multi,
      [:static, "Hello \n"],
      [:newline],
      [:dynamic, "@world"],
      [:newline]
    ])).to eq [:dynamic, ['"Hello \n"', '"#{@world}"', '""'].join("\\\n")]
  end

  it 'should compile static followed by newline' do
    expect(@filter.call([:multi,
      [:static, "Hello \n"],
      [:newline],
      [:code, "world"]
    ])).to eq [:multi,
      [:static, "Hello \n"],
      [:newline],
      [:code, "world"]
    ]
  end
end
