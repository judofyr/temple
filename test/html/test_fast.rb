require 'helper'

describe Temple::HTML::Fast do
  before do
    @html = Temple::HTML::Fast.new
  end

  it 'should compile html doctype' do
    @html.call([:multi, [:html, :doctype, '5']]).should.equal [:multi, [:static, '<!DOCTYPE html>']]
    @html.call([:multi, [:html, :doctype, 'html']]).should.equal [:multi, [:static, '<!DOCTYPE html>']]
    @html.call([:multi, [:html, :doctype, '1.1']]).should.equal [:multi,
      [:static, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">']]
  end

  it 'should compile xml encoding' do
    @html.call([:html, :doctype, 'xml latin1']).should.equal [:static, "<?xml version='1.0' encoding='latin1' ?>"]
  end

  it 'should compile html comment' do
    @html.call([:html, :comment, 'test']).should.equal [:multi, [:static, "<!--"], "test", [:static, "-->"]]
  end

  it 'should compile autoclosed html tag' do
    @html.call([:html, :tag,
      'img', [:attrs],
      false, [:multi]
    ]).should.equal [:multi,
                     [:static, "<img"],
                     [:attrs],
                     [:static, " /"],
                     [:static, ">"], [:multi]]
  end

  it 'should compile explicitly closed html tag' do
    @html.call([:html, :tag,
      'closed', [:attrs],
       true, [:multi]
    ]).should.equal [:multi,
                     [:static, "<closed"],
                     [:attrs],
                     [:static, " /"],
                     [:static, ">"], [:multi]]
  end

  it 'should raise error on closed tag with content' do
    lambda {
      @html.call([:html, :tag,
                     'img', [:attrs],
                     false, [:content]
                    ])
    }.should.raise(RuntimeError).message.should.equal 'Closed tag img has content'
  end

  it 'should compile html with content' do
    @html.call([:html, :tag,
      'div', [:attrs],
      false, [:content]
    ]).should.equal [:multi,
                     [:static, "<div"],
                     [:attrs],
                     [:static, ">"],
                     [:content],
                     [:static, "</div>"]]
  end

  it 'should compile html with static attrs' do
    @html.call([:html, :tag,
      'div',
      [:html, :attrs,
       [:html, :attr, 'id', [:static, 'test']],
       [:html, :attr, 'class', [:dynamic, 'block']]],
       false, [:content]
    ]).should.equal [:multi,
                     [:static,
                      "<div"],
                     [:multi,
                      [:multi,
                       [:capture, "_temple_htmlattr1",
                        [:dynamic, "block"]],
                       [:block, "unless _temple_htmlattr1.empty?"],
                       [:multi,
                        [:static, " "],
                        [:static, "class"],
                        [:static, "="],
                        [:static, "'"],
                        [:dynamic, "_temple_htmlattr1"],
                        [:static, "'"]],
                       [:block, "end"]],
                      [:multi,
                       [:static, " "],
                       [:static, "id"],
                       [:static, "="],
                       [:static, "'"],
                       [:static, "test"],
                       [:static, "'"]]],
                     [:static, ">"],
                     [:content],
                     [:static, "</div>"]]
  end

  it 'should compile html with merged ids' do
    @html.call([:html, :tag,
      'div', [:html, :attrs, [:html, :attr, 'id', [:static, 'a']], [:html, :attr, 'id', [:dynamic, 'b']]],
      false, [:content]
    ]).should.equal [:multi,
                     [:static, "<div"],
                     [:multi,
                      [:multi,
                       [:static, " "],
                       [:static, "id"],
                       [:static, "="],
                       [:static, "'"],
                       [:multi,
                        [:static, 'a'],
                        [:static, '_'],
                        [:dynamic, 'b']],
                       [:static, "'"]]],
                     [:static, ">"],
                     [:content],
                     [:static, "</div>"]]
  end

  it 'should compile html with merged classes' do
    @html.call([:html, :tag,
      'div', [:html, :attrs, [:html, :attr, 'class', [:static, 'a']], [:html, :attr, 'class', [:dynamic, 'b']]],
      false, [:content]
    ]).should.equal [:multi,
                     [:static, "<div"],
                     [:multi,
                      [:multi,
                       [:static, " "],
                       [:static, "class"],
                       [:static, "="],
                       [:static, "'"],
                       [:multi,
                        [:static, 'a'],
                        [:static, ' '],
                        [:dynamic, 'b']],
                       [:static, "'"]]],
                     [:static, ">"],
                     [:content],
                     [:static, "</div>"]]
  end

  it 'should keep blocks intact' do
    exp = [:multi, [:block, 'foo']]
    @html.call(exp).should.equal exp
  end

  it 'should keep statics intact' do
    exp = [:multi, [:static, '<']]
    @html.call(exp).should.equal exp
  end

  it 'should keep dynamic intact' do
    exp = [:multi, [:dynamic, 'foo']]
    @html.call(exp).should.equal exp
  end
end
