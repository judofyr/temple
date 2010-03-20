require File.dirname(__FILE__) + '/helper'

class TestTempleGenerator < Test::Unit::TestCase
  class Simple < Temple::Generator
    def preamble
      buffer " = BUFFER"
    end
    
    def postamble
      buffer
    end
    
    def on_static(s)
      "S:#{s}"
    end
    
    def on_dynamic(s)
      "D:#{s}"
    end
    
    def on_block(s)
      "B:#{s}"
    end
  end
  
  def test_simple_exp
    simple = Simple.new
    
    assert_equal("S:test", simple.compile([:static, "test"]))
    assert_equal("D:test", simple.compile([:dynamic, "test"]))
    assert_equal("B:test", simple.compile([:block, "test"]))
  end
  
  def test_multi
    simple = Simple.new(:buffer => "VAR")
    str = simple.compile([:multi,
      [:static, "static"],
      [:dynamic, "dynamic"],
      [:block, "block"]
    ])
    
    assert_match(/VAR = BUFFER/, str)
    assert_match(/VAR << \(S:static\)/, str)
    assert_match(/VAR << \(D:dynamic\)/, str)
    assert_match(/ B:block /, str)
  end
  
  def test_capture
    simple = Simple.new(:buffer => "VAR")
    str = simple.compile([:capture, "foo", [:static, "test"]])
    
    assert_match(/foo = S:test/, str)
    assert_match(/VAR\Z/, str)
  end
  
  def test_capture_with_multi
    simple = Simple.new(:buffer => "VAR")
    str = simple.compile([:multi,
      [:static, "before"],
      
      [:capture, "foo", [:multi,
        [:static, "static"],
        [:dynamic, "dynamic"],
        [:block, "block"]]],
        
      [:static, "after"]
    ])
    
    assert_match(/VAR << \(S:before\)/, str)
    assert_match(/foo = BUFFER/, str)
    assert_match(/foo << \(S:static\)/, str)
    assert_match(/foo << \(D:dynamic\)/, str)
    assert_match(/ B:block /, str)
    assert_match(/VAR << \(S:after\)/, str)
    assert_match(/VAR\Z/, str)
  end
  
  def test_newlines
    simple = Simple.new(:buffer => "VAR")
    str = simple.compile([:multi,
      [:static, "static"],
      [:newline],
      [:dynamic, "dynamic"],
      [:newline],
      [:block, "block"]
    ])
    
    lines = str.split("\n")
    assert_match(/VAR << \(S:static\)/, lines[0])
    assert_match(/VAR << \(D:dynamic\)/, lines[1])
    assert_match(/ B:block /, lines[2])
  end
  
  def test_to_ruby
    simple = Simple.new
    
    {
      "Hello"              =>   'Hello',
      "Hello\r\nWorld"     =>   'Hello\nWorld',
      "Hello\nWorld"       => %w|Hello World|,
      "Hello\n\r\n\nWorld" => %w|Hello \n World|,
      "\r\n\nHelloWorld\n" => %w|\n HelloWorld .|,
      "\nHelloWorld\r\n"   => %w|. HelloWorld\n|,
    }.
    each do |actual, expected|
      if expected.is_a?(Array)
        expected = expected.map do |x|
          if x == "."
            # Use the dot so we can easily match a newline
            # at the end or the beginning.
            ""
          else
            x
          end
        end.join("\n") 
      end
      
      expected = '"' + expected + '"'
      assert_equal(expected, simple.to_ruby(actual))
    end
  end
end