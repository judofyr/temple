require 'helper'

class TestTempleFiltersEscapeHTML < Test::Unit::TestCase
  def setup
    @filter = Temple::Filters::EscapeHTML.new
  end

  def test_escape_static
    exp = @filter.compile([:multi,
      [:escape, :static, "a < b"],
      [:escape, :dynamic, "ruby_method"]
    ])

    assert_equal([:multi,
      [:static, "a &lt; b"],
      [:dynamic, "Temple::Utils.escape_html((ruby_method))"],
    ], exp)
  end
end
