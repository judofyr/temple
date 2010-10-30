require 'helper'

class TestTempleMultiFlattener < Test::Unit::TestCase
  def setup
    @filter = Temple::Filters::MultiFlattener.new
  end

  def test_flattening
    exp = @filter.compile([:multi,
      [:static, "a"],
      [:multi,
       [:dynamic, "aa"],
       [:multi,
        [:static, "aaa"],
        [:static, "aab"],
       ],
       [:dynamic, "ab"],
      ],
      [:static, "b"],
    ])

    assert_equal([:multi,
      [:static, "a"],
      [:dynamic, "aa"],
      [:static, "aaa"],
      [:static, "aab"],
      [:dynamic, "ab"],
      [:static, "b"],
    ], exp)
  end
end
