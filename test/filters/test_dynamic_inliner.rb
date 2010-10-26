require File.dirname(__FILE__) + '/../helper'

class TestTempleFiltersDynamicInliner < TestFilter(:DynamicInliner)
  def test_several_statics_into_dynamic
    exp = @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World\n "],
      [:static, "Have a nice day"]
    ])

    assert_equal([:multi,
      [:dynamic, '"Hello World\n Have a nice day"']
    ], exp)
  end

  def test_several_dynamics_into_dynamic
    exp = @filter.compile([:multi,
      [:dynamic, "@hello"],
      [:dynamic, "@world"],
      [:dynamic, "@yeah"]
    ])

    assert_equal([:multi,
      [:dynamic, '"#{@hello}#{@world}#{@yeah}"']
    ], exp)
  end

  def test_static_and_dynamic_into_dynamic
    exp = @filter.compile([:multi,
      [:static, "Hello"],
      [:dynamic, "@world"],
      [:dynamic, "@yeah"],
      [:static, "Nice"]
    ])

    assert_equal([:multi,
      [:dynamic, '"Hello#{@world}#{@yeah}Nice"']
    ], exp)
  end

  def test_static_and_dynamic_around_blocks
    exp = @filter.compile([:multi,
      [:static, "Hello "],
      [:dynamic, "@world"],
      [:block, "Oh yeah"],
      [:dynamic, "@yeah"],
      [:static, "Once more"]
    ])

    assert_equal([:multi,
      [:dynamic, '"Hello #{@world}"'],
      [:block, "Oh yeah"],
      [:dynamic, '"#{@yeah}Once more"']
    ], exp)
  end

  def test_keep_blocks_intact
    exp = [:multi, [:block, 'foo']]
    assert_equal(exp, @filter.compile(exp))
  end

  def test_keep_single_static_intact
    exp = [:multi, [:static, 'foo']]
    assert_equal(exp, @filter.compile(exp))
  end

  def test_keep_single_dynamic_intact
    exp = [:multi, [:dynamic, 'foo']]
    assert_equal(exp, @filter.compile(exp))
  end

  def test_inline_inside_multi
    exp = @filter.compile([:multi,
      [:static, "Hello "],
      [:dynamic, "@world"],
      [:multi,
        [:static, "Hello "],
        [:dynamic, "@world"]],
      [:static, "Hello "],
      [:dynamic, "@world"]
    ])

    assert_equal([:multi,
      [:dynamic, '"Hello #{@world}"'],
      [:multi, [:dynamic, '"Hello #{@world}"']],
      [:dynamic, '"Hello #{@world}"']
    ], exp)
  end

  def test_merge_across_newlines
    exp = @filter.compile([:multi,
      [:static, "Hello \n"],
      [:newline],
      [:dynamic, "@world"],
      [:newline]
    ])

    assert_equal([:multi,
      [:dynamic, ['"Hello \n"', '"#{@world}"', '""'].join("\\\n")]
    ], exp)
  end

  def test_static_followed_by_newline
    exp = @filter.compile([:multi,
      [:static, "Hello \n"],
      [:newline],
      [:block, "world"]
    ])

    assert_equal([:multi,
      [:static, "Hello \n"],
      [:newline],
      [:block, "world"]
    ], exp)
  end
end
