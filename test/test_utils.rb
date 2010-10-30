require 'helper'

describe Temple::Utils do
  it 'has empty_exp?' do
    Temple::Utils.empty_exp?([:multi]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi]]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi, [:newline]], [:newline]]).should.be.true
    Temple::Utils.empty_exp?([:multi]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi, [:static, 'text']]]).should.be.false
    Temple::Utils.empty_exp?([:multi, [:newline], [:multi, [:dynamic, 'text']]]).should.be.false
  end

  it 'has escape_html' do
    Temple::Utils.escape_html('<').should.equal '&lt;'
  end

  it 'should escape unsafe html strings' do
    with_html_safe(false) do
      Temple::Utils.escape_html_safe('<').should.equal '&lt;'
    end
  end

  it 'should not escape safe html strings' do
    with_html_safe(true) do
      Temple::Utils.escape_html_safe('<').should.equal '<'
    end
  end
end
