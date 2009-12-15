describe Temple do
  it "has a VERSION" do
    Temple::VERSION.join('.').should =~ /^\d+\.\d+\.\d+$/
  end
end