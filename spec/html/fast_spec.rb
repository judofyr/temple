require 'spec_helper'

describe Temple::HTML::Fast do
  before do
    @html = Temple::HTML::Fast.new
  end

  it 'should compile html doctype' do
    expect(@html.call([:multi, [:html, :doctype, '5']])).to eq([:multi, [:static, '<!DOCTYPE html>']])
    expect(@html.call([:multi, [:html, :doctype, 'html']])).to eq([:multi, [:static, '<!DOCTYPE html>']])
    expect(@html.call([:multi, [:html, :doctype, '1.1']])).to eq [:multi,
      [:static, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">']]
  end

  it 'should compile xml encoding' do
    expect(@html.call([:html, :doctype, 'xml latin1'])).to eq([:static, "<?xml version=\"1.0\" encoding=\"latin1\" ?>"])
  end

  it 'should compile html comment' do
    expect(@html.call([:html, :comment, [:static, 'test']])).to eq([:multi, [:static, "<!--"], [:static, "test"], [:static, "-->"]])
  end

  it 'should compile js wrapped in comments' do
    expect(Temple::HTML::Fast.new(js_wrapper: nil).call([:html, :js, [:static, 'test']])).to eq([:static, "test"])
    expect(Temple::HTML::Fast.new(js_wrapper: :comment).call([:html, :js, [:static, 'test']])).to eq([:multi, [:static, "<!--\n"], [:static, "test"], [:static, "\n//-->"]])
    expect(Temple::HTML::Fast.new(js_wrapper: :cdata).call([:html, :js, [:static, 'test']])).to eq([:multi, [:static, "\n//<![CDATA[\n"], [:static, "test"], [:static, "\n//]]>\n"]])
    expect(Temple::HTML::Fast.new(js_wrapper: :both).call([:html, :js, [:static, 'test']])).to eq([:multi, [:static, "<!--\n//<![CDATA[\n"], [:static, "test"], [:static, "\n//]]>\n//-->"]])
  end

  it 'should guess default js comment' do
    expect(Temple::HTML::Fast.new(js_wrapper: :guess, format: :xhtml).call([:html, :js, [:static, 'test']])).to eq([:multi, [:static, "\n//<![CDATA[\n"], [:static, "test"], [:static, "\n//]]>\n"]])
    expect(Temple::HTML::Fast.new(js_wrapper: :guess, format: :html).call([:html, :js, [:static, 'test']])).to eq([:multi, [:static, "<!--\n"], [:static, "test"], [:static, "\n//-->"]])
  end

  it 'should compile autoclosed html tag' do
    expect(@html.call([:html, :tag,
      'img', [:attrs],
      [:multi, [:newline]]
    ])).to eq [:multi,
                     [:static, "<img"],
                     [:attrs],
                     [:static, " />"],
                     [:multi, [:newline]]]
  end

  it 'should compile explicitly closed html tag' do
    expect(@html.call([:html, :tag,
      'closed', [:attrs]
    ])).to eq [:multi,
                     [:static, "<closed"],
                     [:attrs],
                     [:static, " />"]]
  end

  it 'should compile html with content' do
    expect(@html.call([:html, :tag,
      'div', [:attrs], [:content]
    ])).to eq [:multi,
                     [:static, "<div"],
                     [:attrs],
                     [:static, ">"],
                     [:content],
                     [:static, "</div>"]]
  end

  it 'should compile html with attrs' do
    expect(@html.call([:html, :tag,
      'div',
      [:html, :attrs,
       [:html, :attr, 'id', [:static, 'test']],
       [:html, :attr, 'class', [:dynamic, 'block']]],
       [:content]
    ])).to eq [:multi,
                     [:static, "<div"],
                     [:multi,
                      [:multi, [:static, " id=\""], [:static, "test"], [:static, '"']],
                      [:multi, [:static, " class=\""], [:dynamic, "block"], [:static, '"']]],
                     [:static, ">"],
                     [:content],
                     [:static, "</div>"]]
  end

  it 'should keep codes intact' do
    exp = [:multi, [:code, 'foo']]
    expect(@html.call(exp)).to eq(exp)
  end

  it 'should keep statics intact' do
    exp = [:multi, [:static, '<']]
    expect(@html.call(exp)).to eq(exp)
  end

  it 'should keep dynamic intact' do
    exp = [:multi, [:dynamic, 'foo']]
    expect(@html.call(exp)).to eq(exp)
  end
end
