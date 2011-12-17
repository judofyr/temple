require 'stringio'
describe Temple::Filters::NewlineAdjuster do

  it "should do nothing if everything is fine" do
    na = Temple::Filters::NewlineAdjuster.new(:newlines => 3)
    na.call([:multi, [:newline],[:newline],[:newline]]).should == [:multi, [:newline],[:newline],[:newline]]
  end

  it "should add newlines if required" do
    na = Temple::Filters::NewlineAdjuster.new(:newlines => 5)
    na.call([:foo]).should == [:multi, [:foo],[:newline],[:newline],[:newline],[:newline],[:newline]]
  end

  it "should add preceding newlines if more appropriate" do
    na = Temple::Filters::NewlineAdjuster.new(:newlines => 5, :preceding_newlines => 2)
    na.call([:foo]).should == [:multi, [:newline],[:newline],[:foo],[:newline],[:newline],[:newline]]
  end

  it "should not add more preceding newlines than required" do
    na = Temple::Filters::NewlineAdjuster.new(:newlines => 5, :preceding_newlines => 4)
    na.call([:foo, [:newline],[:newline]]).should == [:multi, [:newline],[:newline],[:newline],[:foo,[:newline],[:newline]]]
  end

  it "should raise if specified and expression cannot be cropped" do
    na = Temple::Filters::NewlineAdjuster.new(:newlines => 1, :on_problem => :raise, :crop => false)
    should.raise{ na.call([:code, "foo\nbar\n"]) }
  end

  it "should warn if specified and expression cannot be cropped" do
    na = Temple::Filters::NewlineAdjuster.new(:newlines => 1, :on_problem => :warn, :crop => false)
    begin
      stderr, $stderr = $stderr, StringIO.new(str = "")
      na.call([:code, "foo\nbar\n"])
      str.should =~ /Can't adjust given tree to contain/
    ensure
      $stderr = stderr
    end
  end

  it "should do nothing if specified and expression cannot be cropped" do
    na = Temple::Filters::NewlineAdjuster.new(:newlines => 1, :on_problem => false, :crop => false)
    begin
      stderr, $stderr = $stderr, StringIO.new(str = "")
      na.call([:code, "foo\nbar\n"])
      str.should.not =~ /Can't adjust given tree to contain/
    ensure
      $stderr = stderr
    end
  end

end
