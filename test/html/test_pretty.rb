require 'helper'

describe Temple::HTML::Pretty do
  before do
    @html = Temple::HTML::Pretty.new
  end

  it 'should indent nested tags' do
    @html.call([:html, :tag, 'div', [:multi], false,
      [:html, :tag, 'p', [:multi], false, [:multi, [:static, 'text'], [:dynamic, 'code']]]
    ]).should.equal [:multi,
                     [:block, "_temple_html_pretty1 = /<pre|<textarea/"],
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
                        [:multi,
                         [:block, "_temple_html_pretty2 = (code).to_s"],
                         [:block, '_temple_html_pretty2.gsub!("\n", "\n    ") if _temple_html_pretty1 !~ _temple_html_pretty2'],
                         [:dynamic, "_temple_html_pretty2"]]],
                       [:static, "</p>"]],
                      [:static, "\n</div>"]]]
  end


  it 'should not indent preformatted tags' do
    @html.call([:html, :tag, 'pre', [:multi], false,
      [:html, :tag, 'p', [:multi], false, [:static, 'text']]
    ]).should.equal [:multi,
                     [:block, "_temple_html_pretty1 = /<pre|<textarea/"],
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
