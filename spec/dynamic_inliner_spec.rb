require File.dirname(__FILE__) + '/spec_helper.rb'

describe_filter :DynamicInliner do
  it "should merge several statics into dynamic" do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World\n "],
      [:static, "Have a nice day"]
    ]).should == [:multi,
      [:dynamic, "\"Hello World\n Have a nice day\""]
    ]
  end
  
  it "should merge several dynamics into a single dynamic" do
    @filter.compile([:multi,
      [:dynamic, "@hello"],
      [:dynamic, "@world"],
      [:dynamic, "@yeah"]
    ]).should == [:multi,
      [:dynamic, '"#{@hello}#{@world}#{@yeah}"']
    ]
  end
  
  it "should merge static+dynamic into dynamic" do
    @filter.compile([:multi,
      [:static, "Hello"],
      [:dynamic, "@world"],
      [:dynamic, "@yeah"],
      [:static, "Nice"]
    ]).should == [:multi,
      [:dynamic, '"Hello#{@world}#{@yeah}Nice"']
    ]
  end
  
  it "should merge static+dynamic around blocks" do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:dynamic, "@world"],
      [:block, "Oh yeah"],
      [:dynamic, "@yeah"],
      [:static, "Once more"]
    ]).should == [:multi,
      [:dynamic, '"Hello #{@world}"'],
      [:block, "Oh yeah"],
      [:dynamic, '"#{@yeah}Once more"']
    ]
  end
  
  it "should keep blocks intact" do
    exp = [:multi, [:block, 'foo']]
    @filter.compile(exp).should == exp
  end
  
  it "should keep single static intact" do
    exp = [:multi, [:static, 'foo']]
    @filter.compile(exp).should == exp
  end

  it "should keep single dynamic intact" do
    exp = [:multi, [:dynamic, 'foo']]
    @filter.compile(exp).should == exp
  end
  
  it "should inline inside multi" do
    @filter.compile([:multi,
      [:static, "Hello "],
      [:dynamic, "@world"],
      [:multi,
        [:static, "Hello "],
        [:dynamic, "@world"]],
      [:static, "Hello "],
      [:dynamic, "@world"]
    ]).should == [:multi,
      [:dynamic, '"Hello #{@world}"'],
      [:multi, [:dynamic, '"Hello #{@world}"']],
      [:dynamic, '"Hello #{@world}"']
    ]
  end
  
  it "should merge across newlines" do
    @filter.compile([:multi,
      [:static, "Hello \n"],
      [:newline],
      [:dynamic, "@world"],
      [:newline]
    ]).should == [:multi,
      [:dynamic, ["\"Hello \n\"", '"#{@world}"', '""'].join("\\\n")],
    ]
  end
  
  it "should handle static followed by a newline" do
    @filter.compile([:multi,
      [:static, "Hello \n"],
      [:newline],
      [:block, "world"]
    ]).should == [:multi,
      [:static, "Hello \n"],
      [:newline],
      [:block, "world"]
    ]
  end
end