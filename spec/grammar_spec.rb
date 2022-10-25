require 'spec_helper'

describe Temple::Grammar do
  it 'should match core expressions' do
    expect(Temple::Grammar).to be_match([:multi])
    expect(Temple::Grammar).to be_match([:multi, [:multi]])
    expect(Temple::Grammar).to be_match([:static, 'Text'])
    expect(Temple::Grammar).to be_match([:dynamic, 'Text'])
    expect(Temple::Grammar).to be_match([:code, 'Text'])
    expect(Temple::Grammar).to be_match([:capture, 'Text', [:multi]])
    expect(Temple::Grammar).to be_match([:newline])
  end

  it 'should not match invalid core expressions' do
    expect(Temple::Grammar).not_to be_match([:multi, 'String'])
    expect(Temple::Grammar).not_to be_match([:static])
    expect(Temple::Grammar).not_to be_match([:dynamic, 1])
    expect(Temple::Grammar).not_to be_match([:code, :sym])
    expect(Temple::Grammar).not_to be_match([:capture, [:multi]])
    expect(Temple::Grammar).not_to be_match([:newline, [:multi]])
  end

  it 'should match control flow expressions' do
    expect(Temple::Grammar).to be_match([:if, 'Condition', [:multi]])
    expect(Temple::Grammar).to be_match([:if, 'Condition', [:multi], [:multi]])
    expect(Temple::Grammar).to be_match([:block, 'Loop', [:multi]])
    expect(Temple::Grammar).to be_match([:case, 'Arg', ['Cond1', [:multi]], ['Cond1', [:multi]], [:else, [:multi]]])
    expect(Temple::Grammar).not_to be_match([:case, 'Arg', [:sym, [:multi]]])
    expect(Temple::Grammar).to be_match([:cond, ['Cond1', [:multi]], ['Cond2', [:multi]], [:else, [:multi]]])
    expect(Temple::Grammar).not_to be_match([:cond, [:sym, [:multi]]])
  end

  it 'should match escape expression' do
    expect(Temple::Grammar).to be_match([:escape, true, [:multi]])
    expect(Temple::Grammar).to be_match([:escape, false, [:multi]])
  end

  it 'should match html expressions' do
    expect(Temple::Grammar).to be_match([:html, :doctype, 'Doctype'])
    expect(Temple::Grammar).to be_match([:html, :comment, [:multi]])
    expect(Temple::Grammar).to be_match([:html, :tag, 'Tag', [:multi]])
    expect(Temple::Grammar).to be_match([:html, :tag, 'Tag', [:multi], [:multi]])
    expect(Temple::Grammar).to be_match([:html, :tag, 'Tag', [:multi], [:static, 'Text']])
    expect(Temple::Grammar).to be_match([:html, :tag, 'Tag', [:html, :attrs, [:html, :attr, 'id',
                                  [:static, 'val']]], [:static, 'Text']])
  end
end
