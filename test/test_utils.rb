require 'helper'

class TestTempleUtils < Test::Unit::TestCase
  def test_empty_exp
    assert_equal true, Temple::Utils.empty_exp?([:multi])
    assert_equal true, Temple::Utils.empty_exp?([:multi, [:multi]])
    assert_equal true, Temple::Utils.empty_exp?([:multi, [:multi, [:newline]], [:newline]])
    assert_equal true, Temple::Utils.empty_exp?([:multi])
    assert_equal false, Temple::Utils.empty_exp?([:multi, [:multi, [:static, "text"]]])
    assert_equal false, Temple::Utils.empty_exp?([:multi, [:newline], [:multi, [:dynamic, "text"]]])
  end

  def test_escape_html
    assert_equal "&lt;", Temple::Utils.escape_html("<")
  end

  def test_escape_html_safe_with_unsafe
    String.send(:define_method, :html_safe?) { false }
    assert_equal "&lt;", Temple::Utils.escape_html_safe("<")
  ensure
    String.send(:undef_method, :html_safe?) if String.method_defined?(:html_safe?)
  end

  def test_escape_html_safe_with_safe
    String.send(:define_method, :html_safe?) { true }
    assert_equal "<", Temple::Utils.escape_html_safe("<")
  ensure
    String.send(:undef_method, :html_safe?) if String.method_defined?(:html_safe?)
  end
end
