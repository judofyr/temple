require File.dirname(__FILE__) + '/spec_helper.rb'

describe_filter :StaticMerger do
  it "should merge several statics" do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:static, "Good night"]
    ]).should == [:multi,
      [:static, "Hello World, Good night"]
    ]
  end
  
  it "should merge several statics around block" do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World!"],
      [:block, "123"],
      [:static, "Good night, "],
      [:static, "everybody"]
    ]).should == [:multi,
      [:static, "Hello World!"],
      [:block, "123"],
      [:static, "Good night, everybody"]
    ]
  end
  
  it "should merge across newlines" do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:newline],
      [:static, "Good night"]
    ]).should == [:multi,
      [:static, "Hello World, Good night"],
      [:newline]
    ]
  end
end
