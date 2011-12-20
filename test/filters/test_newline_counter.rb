describe Temple::Filters::NewlineCounter do

  before do
    @nc = Temple::Filters::NewlineCounter.new
  end

  it "should count :code without newlines correctly" do
    @nc.call( [:code, "foo" ] )
    @nc.newlines.should == 0
    @nc.preceding_newlines.should == 0
    @nc.succeding_newlines.should == 0
  end

  it "should count :static without newlines correctly" do
    @nc.call( [:static, "foo" ] )
    @nc.newlines.should == 0
    @nc.preceding_newlines.should == 0
    @nc.succeding_newlines.should == 0
  end

  it "should count :newlines" do
    @nc.call( [:newline] )
    @nc.newlines.should == 1
    @nc.preceding_newlines.should == 1
    @nc.succeding_newlines.should == 0
  end

  it "should count :newlines inside :multi" do
    @nc.call( [:multi, [:newline], [:newline], [:newline]] )
    @nc.newlines.should == 3
    @nc.preceding_newlines.should == 3
    @nc.succeding_newlines.should == 0
  end

  it "should get preceding/succeding newlines right" do
    @nc.call( [:multi, [:newline], [:newline], [:static,'foo'], [:newline]] )
    @nc.newlines.should == 3
    @nc.preceding_newlines.should == 2
    @nc.succeding_newlines.should == 1
  end

  it "should count :code correctly" do
    @nc.call( [:code, "foo\nbar" ] )
    @nc.newlines.should == 1
    @nc.preceding_newlines.should == 0
    @nc.succeding_newlines.should == 0
  end

  it "should count :code with preceding newlines correctly" do
    @nc.call( [:code, "\n\n\nfoo\nbar" ] )
    @nc.newlines.should == 4
    @nc.preceding_newlines.should == 3
    @nc.succeding_newlines.should == 0
  end

  it "should count :code with succeding newlines correctly" do
    @nc.call( [:code, "foo\nbar\n\n\n" ] )
    @nc.newlines.should == 4
    @nc.preceding_newlines.should == 0
    @nc.succeding_newlines.should == 3
  end

  it "should count inside unknown expressions" do
    @nc.call( [:foo, [:newline], [:newline], [:static,'foo'], [:newline]] )
    @nc.newlines.should == 3
    @nc.preceding_newlines.should == 0
    @nc.succeding_newlines.should == 1
  end

end
