require 'spec_helper'

describe Temple::Filters::CodeMerger do
  before do
    @filter = Temple::Filters::CodeMerger.new
  end

  it 'should merge serveral codes' do
    expect(@filter.call([:multi,
      [:code, "a"],
      [:code, "b"],
      [:code, "c"]
    ])).to eq [:code, "a; b; c"]
  end

  it 'should merge serveral codes around static' do
    expect(@filter.call([:multi,
      [:code, "a"],
      [:code, "b"],
      [:static, "123"],
      [:code, "a"],
      [:code, "b"]
    ])).to eq [:multi,
      [:code, "a; b"],
      [:static, "123"],
      [:code, "a; b"]
    ]
  end

  it 'should merge serveral codes with newlines' do
    expect(@filter.call([:multi,
      [:code, "a"],
      [:code, "b"],
      [:newline],
      [:code, "c"]
    ])).to eq [:code, "a; b\nc"]
  end
end
