require 'helper'

describe Temple::Filters::Escapable do
  before do
    @filter = Temple::Filters::Escapable.new
  end

  it 'should handle escape expressions' do
    @filter.call([:escape, true,
                  [:multi,
                   [:static, "a < b"],
                   [:dynamic, "ruby_method"]]
    ]).should.equal [:multi,
      [:static, "a &lt; b"],
      [:dynamic, "::Temple::Utils.escape_html_safe((ruby_method))"],
    ]
  end

  it 'should keep codes intact' do
    exp = [:multi, [:code, 'foo']]
    @filter.call(exp).should.equal exp
  end

  it 'should keep statics intact' do
    exp = [:multi, [:static, '<']]
    @filter.call(exp).should.equal exp
  end

  it 'should keep dynamic intact' do
    exp = [:multi, [:dynamic, 'foo']]
    @filter.call(exp).should.equal exp
  end

  it 'should not escape html safe statics' do
    with_html_safe do
      @filter.call([:escape, true,
        [:static, "a < b".html_safe]
      ]).should.equal [:static, "a < b"]
    end
  end

  it 'should support censoring' do
    filter = Temple::Filters::Escapable.new(:escape_code => '(%s).gsub("Temple sucks", "Temple rocks")')
    filter.call([:escape, true,
      [:static, "~~ Temple sucks ~~"]
    ]).should.equal [:static, "~~ Temple rocks ~~"]
  end
end
