require File.dirname(__FILE__) + '/../helper'

class TestTempleFiltersEscapable < TestFilter(:Escapable)
  def test_escape
    exp = @filter.compile([:multi,
      [:escape, [:dynamic, "@hello"]],
      [:escape, [:block, "@world"]]
    ])
    
    assert_equal([:multi,
      [:dynamic, "CGI.escapeHTML((@hello).to_s)"],
      [:block, "CGI.escapeHTML((@world).to_s)"]
    ], exp)
  end

  def test_escape_static_content
    exp = @filter.compile([:multi,
      [:escape, [:static, "<hello>"]],
      [:escape, [:block, "@world"]]
    ])
    
    assert_equal([:multi,
      [:static, "&lt;hello&gt;"],
      [:block, "CGI.escapeHTML((@world).to_s)"]
    ], exp)
  end
end

