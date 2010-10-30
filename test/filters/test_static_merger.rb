require 'helper'

describe Temple::Filters::StaticMerger do
  before do
    @filter = Temple::Filters::StaticMerger.new
  end

  it 'should merge serveral statics' do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:static, "Good night"]
    ]).should.equal [:multi,
      [:static, "Hello World, Good night"]
    ]
  end

  it 'should merge serveral statics around block' do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World!"],
      [:block, "123"],
      [:static, "Good night, "],
      [:static, "everybody"]
    ]).should.equal [:multi,
      [:static, "Hello World!"],
      [:block, "123"],
      [:static, "Good night, everybody"]
    ]
  end

  it 'should merge serveral statics across newlines' do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:newline],
      [:static, "Good night"]
    ]).should.equal [:multi,
      [:static, "Hello World, Good night"],
      [:newline]
    ]
  end
end
