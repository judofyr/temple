require 'helper'

describe Temple::Filters::MultiFlattener do
  before do
    @filter = Temple::Filters::MultiFlattener.new
  end

  it 'should flatten nested multi expressions' do
    @filter.compile([:multi,
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
    ]).should.equal [:multi,
      [:static, "a"],
      [:dynamic, "aa"],
      [:static, "aaa"],
      [:static, "aab"],
      [:dynamic, "ab"],
      [:static, "b"],
    ]
  end

  it 'should return first element' do
    @filter.compile([:multi, [:block, 'foo']]).should.equal [:block, 'foo']
  end
end
