require 'spec_helper'

describe Temple::Filters::Eraser do
  it 'should respect keep' do
    eraser = Temple::Filters::Eraser.new(keep: [:a])
    expect(eraser.call([:multi,
      [:a],
      [:b],
      [:c]
    ])).to eq [:multi,
      [:a],
      [:multi],
      [:multi]
    ]
  end

  it 'should respect erase' do
    eraser = Temple::Filters::Eraser.new(erase: [:a])
    expect(eraser.call([:multi,
      [:a],
      [:b],
      [:c]
    ])).to eq [:multi,
      [:multi],
      [:b],
      [:c]
    ]
  end

  it 'should choose erase over keep' do
    eraser = Temple::Filters::Eraser.new(keep: [:a, :b], erase: [:a])
    expect(eraser.call([:multi,
      [:a],
      [:b],
      [:c]
    ])).to eq [:multi,
      [:multi],
      [:b],
      [:multi]
    ]
  end

  it 'should erase nested types' do
    eraser = Temple::Filters::Eraser.new(erase: [[:a, :b]])
    expect(eraser.call([:multi,
      [:a, :a],
      [:a, :b],
      [:b]
    ])).to eq [:multi,
      [:a, :a],
      [:multi],
      [:b]
    ]
  end
end
