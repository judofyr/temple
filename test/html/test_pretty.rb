require 'helper'

describe Temple::HTML::Pretty do
  before do
    @html = Temple::HTML::Pretty.new
  end

  it 'should indent nested tags' do
    @html.compile([:html, :tag, 'div', [:multi], false,
      [:html, :tag, 'p', [:multi], false, [:static, 'text']]
    ]).should.equal [:multi,
                     [:static, "<div"],
                     [:multi],
                     [:static, ">"],
                     [:multi,
                      [:static, "\n  <p"],
                      [:multi],
                      [:static, ">"],
                      [:static, "text"],
                      [:static, "</p>"]],
                     [:static, "\n</div>"]]
  end


  it 'should not indent preformatted tags' do
    @html.compile([:html, :tag, 'pre', [:multi], false,
      [:html, :tag, 'p', [:multi], false, [:static, 'text']]
    ]).should.equal [:multi,
                     [:static, "<pre"],
                     [:multi],
                     [:static, ">"],
                     [:multi,
                      [:static, "<p"],
                      [:multi],
                      [:static, ">"],
                      [:static, "text"],
                      [:static, "</p>"]],
                     [:static, "\n</pre>"]]
  end
end
