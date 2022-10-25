require 'spec_helper'

class UniqueTest
  include Temple::Utils
end

describe Temple::Utils do
  it 'has empty_exp?' do
    expect(Temple::Utils.empty_exp?([:multi])).to eq(true)
    expect(Temple::Utils.empty_exp?([:multi, [:multi]])).to eq(true)
    expect(Temple::Utils.empty_exp?([:multi, [:multi, [:newline]], [:newline]])).to eq(true)
    expect(Temple::Utils.empty_exp?([:multi])).to eq(true)
    expect(Temple::Utils.empty_exp?([:multi, [:multi, [:static, 'text']]])).to eq(false)
    expect(Temple::Utils.empty_exp?([:multi, [:newline], [:multi, [:dynamic, 'text']]])).to eq(false)
  end

  it 'has unique_name' do
    u = UniqueTest.new
    expect(u.unique_name).to eq('_uniquetest1')
    expect(u.unique_name).to eq('_uniquetest2')
    expect(UniqueTest.new.unique_name).to eq('_uniquetest1')
  end

  it 'has escape_html' do
    expect(Temple::Utils.escape_html('<')).to eq('&lt;')
  end

  it 'should escape unsafe html strings' do
    with_html_safe do
      expect(Temple::Utils.escape_html_safe('<')).to eq('&lt;')
    end
  end

  it 'should not escape safe html strings' do
    with_html_safe do
      expect(Temple::Utils.escape_html_safe('<'.html_safe)).to eq('<')
    end
  end
end
