require 'helper'
begin
  require 'ripper'
rescue LoadError
end

if defined?(Ripper)
  describe Temple::Filters::StaticAnalyzer do
    before do
      @filter = Temple::Filters::StaticAnalyzer.new
    end

    it 'should convert :dynamic to :static if code is static' do
      @filter.call([:dynamic, '"#{"hello"}#{100}"']
      ).should.equal [:static, 'hello100']
    end

    it 'should not convert :dynamic if code is dynamic' do
      exp = [:dynamic, '"#{hello}#{100}"']
      @filter.call(exp).should.equal(exp)
    end
  end
end
