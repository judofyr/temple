require 'temple'

module TestHelper
  def with_html_safe
    require 'temple/html/safe'
    String.send(:define_method, :html_safe?) { false }
    String.send(:define_method, :html_safe) { Temple::HTML::SafeString.new(self) }
    yield
  ensure
    String.send(:undef_method, :html_safe?) if String.method_defined?(:html_safe?)
    String.send(:undef_method, :html_safe) if String.method_defined?(:html_safe)
  end

  def grammar_validate(grammar, exp, message)
    expect { grammar.validate!(exp) }.to raise_error(Temple::InvalidExpression, message)
  end

  def erb(src, options = {})
    Temple::ERB::Template.new(options) { src }.render
  end

  def erubi(src, options = {})
    Tilt::ErubiTemplate.new(options) { src }.render
  end
end

RSpec.configure do |config|
  config.include TestHelper
end
