require 'bacon'
require 'temple'

module TestHelper
  def with_html_safe(flag)
    String.send(:define_method, :html_safe?) { flag }
    yield
  ensure
    String.send(:undef_method, :html_safe?) if String.method_defined?(:html_safe?)
  end
end

class Bacon::Context
  include TestHelper
end
