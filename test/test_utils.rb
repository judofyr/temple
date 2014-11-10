require 'helper'

class UniqueTest
  include Temple::Utils
end

describe Temple::Utils do
  it 'has empty_exp?' do
    Temple::Utils.empty_exp?([:multi]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi]]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi, [:newline]], [:newline]]).should.be.true
    Temple::Utils.empty_exp?([:multi]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi, [:static, 'text']]]).should.be.false
    Temple::Utils.empty_exp?([:multi, [:newline], [:multi, [:dynamic, 'text']]]).should.be.false
  end

  it 'has unique_name' do
    u = UniqueTest.new
    u.unique_name.should.equal '_uniquetest1'
    u.unique_name.should.equal '_uniquetest2'
    UniqueTest.new.unique_name.should.equal '_uniquetest1'
  end

  it '#escape_html escapes unsafe html strings' do
    Temple::Utils.escape_html('<').should.equal '&lt;'
  end

  it '#escape_html escapes safe html strings' do
    with_html_safe do
      Temple::Utils.escape_html('<'.html_safe).should.equal '&lt;'
    end
  end

  it "#escape_html_safe does not fail when used with strings without html safety patch" do
    Temple::Utils.escape_html_safe('<').should.equal '&lt;'
  end

  it '#escape_html_safe escapes unsafe html strings' do
    with_html_safe do
      Temple::Utils.escape_html_safe('<').should.equal '&lt;'
    end
  end

  it '#escape_html_safe does not escape safe html strings' do
    with_html_safe do
      Temple::Utils.escape_html_safe('<'.html_safe).should.equal '<'
    end
  end
end
