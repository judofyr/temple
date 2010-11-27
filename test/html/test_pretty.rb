require 'helper'

describe Temple::HTML::Pretty do
  before do
    @html = Temple::HTML::Pretty.new
  end

  it 'should indent nested tags' do
    @html.compile([:html, :tag, 'div', [:multi], false,
      [:html, :tag, 'p', [:multi], false, [:multi, [:static, 'text'], [:dynamic, 'code']]]
    ]).should.equal [:multi,
                     [:block, "_temple_pre_tags = /<pre|<textarea/"],
                     [:multi,
                      [:static, "<div"],
                      [:multi],
                      [:static, ">"],
                      [:multi,
                       [:static, "\n  <p"],
                       [:multi],
                       [:static, ">"],
                       [:multi,
                        [:static, "text"],
                       [:dynamic, 'Temple::Utils.indent((code), "\n    ", _temple_pre_tags)']],
                       [:static, "</p>"]],
                      [:static, "\n</div>"]]]
  end


  it 'should not indent preformatted tags' do
    @html.compile([:html, :tag, 'pre', [:multi], false,
      [:html, :tag, 'p', [:multi], false, [:static, 'text']]
    ]).should.equal [:multi,
                     [:block, "_temple_pre_tags = /<pre|<textarea/"],
                     [:multi,
                      [:static, "<pre"],
                      [:multi],
                      [:static, ">"],
                      [:multi,
                       [:static, "<p"],
                       [:multi],
                       [:static, ">"],
                       [:static, "text"],
                       [:static, "</p>"]],
                      [:static, "</pre>"]]]
  end
end
