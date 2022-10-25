require 'spec_helper'

describe Temple::Filters::MultiFlattener do
  before do
    @filter = Temple::Filters::MultiFlattener.new
  end

  it 'should flatten nested multi expressions' do
    expect(@filter.call([:multi,
      [:static, "a"],
      [:multi,
       [:dynamic, "aa"],
       [:multi,
        [:static, "aaa"],
        [:static, "aab"],
       ],
       [:dynamic, "ab"],
      ],
      [:static, "b"],
    ])).to eq [:multi,
      [:static, "a"],
      [:dynamic, "aa"],
      [:static, "aaa"],
      [:static, "aab"],
      [:dynamic, "ab"],
      [:static, "b"],
    ]
  end

  it 'should return first element' do
    expect(@filter.call([:multi, [:code, 'foo']])).to eq([:code, 'foo'])
  end
end
