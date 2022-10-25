require 'spec_helper'

describe Temple::Filters::StaticMerger do
  before do
    @filter = Temple::Filters::StaticMerger.new
  end

  it 'should merge serveral statics' do
    expect(@filter.call([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:static, "Good night"]
    ])).to eq [:static, "Hello World, Good night"]
  end

  it 'should merge serveral statics around code' do
    expect(@filter.call([:multi,
      [:static, "Hello "],
      [:static, "World!"],
      [:code, "123"],
      [:static, "Good night, "],
      [:static, "everybody"]
    ])).to eq [:multi,
      [:static, "Hello World!"],
      [:code, "123"],
      [:static, "Good night, everybody"]
    ]
  end

  it 'should merge serveral statics across newlines' do
    expect(@filter.call([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:newline],
      [:static, "Good night"]
    ])).to eq [:multi,
      [:static, "Hello World, Good night"],
      [:newline]
    ]
  end
end
