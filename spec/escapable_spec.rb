require File.dirname(__FILE__) + '/spec_helper.rb'
require 'cgi'

describe_filter :Escapable do
  it "should escape everywhere" do
    @filter.compile([:multi,
      [:dynamic, [:escape, "@hello"]],
      [:block, [:escape, "@world"]]
    ]).should == [:multi,
      [:dynamic, "CGI.escapeHTML(@hello.to_s)"],
      [:block, "CGI.escapeHTML(@world.to_s)"]
    ]
  end
  
  it "should automatically escape static content" do
    @filter.compile([:multi,
      [:static, [:escape, "<hello>"]],
      [:block, [:escape, "@world"]]
    ]).should == [:multi,
      [:static, "&lt;hello&gt;"],
      [:block, "CGI.escapeHTML(@world.to_s)"]
    ]
  end
end