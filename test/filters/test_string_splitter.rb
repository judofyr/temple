require 'helper'
begin
  require 'ripper'
rescue LoadError
end

if defined?(Ripper)
  describe Temple::Filters::StringSplitter do
    before do
      @filter = Temple::Filters::StringSplitter.new
    end

    it 'should split :dynamic with string literal' do
      @filter.call([:dynamic, '"static#{dynamic}"']
      ).should.equal [:multi, [:static, 'static'], [:dynamic, 'dynamic']]
    end
  end
end
