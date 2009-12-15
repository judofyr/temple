require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Temple::Parsers::ERB do
  it "compiles simple static ERB" do
    Temple::Parsers::ERB.new.compile("Hello!").should == [:multi, [:static, "Hello!"]]
  end

  it "compiles simple dynamic ERB to a single dynamic" do
    Temple::Parsers::ERB.new.compile("<%='Hello!'%>").should == [:multi, [:dynamic, "'Hello!'"]]
  end

  it "compiles dynamic/static mix" do
    Temple::Parsers::ERB.new.compile("Oh <%='Hello'%> Jon!").should == [:multi, [:static, "Oh "], [:dynamic, "'Hello'"], [:static, " Jon!"]]
  end
end