require File.dirname(__FILE__) + '/../helper'

class TestTempleFiltersStaticMerger < TestFilter(:StaticMerger)
  def test_several_statics
    exp = @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:static, "Good night"]
    ])
    
    assert_equal([:multi,
      [:static, "Hello World, Good night"]
    ], exp)
  end
  
  def test_several_statics_around_block
    exp = @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World!"],
      [:block, "123"],
      [:static, "Good night, "],
      [:static, "everybody"]
    ])
    
    assert_equal([:multi,
      [:static, "Hello World!"],
      [:block, "123"],
      [:static, "Good night, everybody"]
    ], exp)
  end
  
  def test_several_statics_across_newlines
    exp = @filter.compile([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:newline],
      [:static, "Good night"]
    ])
    
    assert_equal([:multi,
      [:static, "Hello World, Good night"],
      [:newline]
    ], exp)
  end
end