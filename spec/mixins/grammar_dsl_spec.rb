require 'spec_helper'

module BasicGrammar
  extend Temple::Mixins::GrammarDSL

  Expression <<
    Symbol |
    Answer |
    [:zero_or_more, 'Expression*'] |
    [:one_or_more,  'Expression+'] |
    [:zero_or_one,  'Expression?'] |
    [:bool, Bool] |
    nil

  Bool <<
    true | false

  Answer <<
    Value(42)

end

module ExtendedGrammar
  extend BasicGrammar

  Expression << [:extended, Expression]
end

describe Temple::Mixins::GrammarDSL do
  it 'should support class types' do
    expect(BasicGrammar).to be_match(:symbol)
    expect(BasicGrammar).not_to be_match([:symbol])
    expect(BasicGrammar).not_to be_match('string')
    expect(BasicGrammar).not_to be_match(['string'])
  end

  it 'should support value types' do
    expect(BasicGrammar).to be_match(42)
    expect(BasicGrammar).not_to be_match(43)
  end

  it 'should support nesting' do
    expect(BasicGrammar).to be_match([:zero_or_more, [:zero_or_more]])
  end

  it 'should support *' do
    expect(BasicGrammar).to be_match([:zero_or_more])
    expect(BasicGrammar).to be_match([:zero_or_more, nil, 42])
  end

  it 'should support +' do
    expect(BasicGrammar).not_to be_match([:one_or_more])
    expect(BasicGrammar).to be_match(    [:one_or_more, 42])
    expect(BasicGrammar).to be_match(    [:one_or_more, 42, nil])
  end

  it 'should support ?' do
    expect(BasicGrammar).not_to be_match([:zero_or_one, nil, 42])
    expect(BasicGrammar).to be_match(    [:zero_or_one])
    expect(BasicGrammar).to be_match(    [:zero_or_one, 42])
  end

  it 'should support extended grammars' do
    expect(ExtendedGrammar).to be_match([:extended, [:extended, 42]])
    expect(BasicGrammar).not_to be_match([:zero_or_more, [:extended, nil]])
    expect(BasicGrammar).not_to be_match([:extended, [:extended, 42]])
  end

  it 'should have validate!' do
    grammar_validate BasicGrammar,
                     [:zero_or_more, [:zero_or_more, [:unknown]]],
                     "BasicGrammar::Expression did not match\n[:unknown]\n"

    grammar_validate BasicGrammar,
                     [:zero_or_more, [:one_or_more]],
                     "BasicGrammar::Expression did not match\n[:one_or_more]\n"

    grammar_validate BasicGrammar,
                     [:zero_or_more, 123, [:unknown]],
                     "BasicGrammar::Expression did not match\n123\n"

    grammar_validate BasicGrammar,
                     [:bool, 123],
                     "BasicGrammar::Bool did not match\n123\n"
  end
end
