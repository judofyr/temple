require 'helper'
begin
  require 'ripper'
rescue LoadError
end

if defined?(Ripper) && RUBY_VERSION >= "2.0.0"
  describe Temple::Filters::StringSplitter do
    before do
      @filter = Temple::Filters::StringSplitter.new
    end

    {
      %q|''|                     => [:multi],
      %q|""|                     => [:multi],
      %q|"hello"|                => [:multi, [:static, 'hello']],
      %q|"hello #{}world"|       => [:multi, [:static, 'hello '], [:static, 'world']],
      %q|"#{hello}"|             => [:multi, [:dynamic, 'hello']],
      %q|"nya#{123}"|            => [:multi, [:static, 'nya'], [:dynamic, '123']],
      %q|"#{()}()"|              => [:multi, [:dynamic, '()'], [:static, '()']],
      %q|" #{ " #{ '#{}' } " }"| => [:multi, [:static, ' '], [:multi, [:static, ' '], [:multi, [:static, '#{}']], [:static, ' ']]],
      %q|%Q[a#{b}c#{d}e]|        => [:multi, [:static, 'a'], [:dynamic, 'b'], [:static, 'c'], [:dynamic, 'd'], [:static, 'e']],
      %q|%q[a#{b}c#{d}e]|        => [:multi, [:static, 'a#{b}c#{d}e']],
      %q|"\#{}#{123}"|           => [:multi, [:static, '#{}'], [:dynamic, '123']],
      %q|"#{ '}' }"|             => [:multi, [:multi, [:static, '}']]],
      %q| "a" # hello |          => [:multi, [:static, 'a']],
      %q|"\""|                   => [:multi, [:static, '"']],
      %q|"\\\\\\""|              => [:multi, [:static, '\\"']],
      %q|'\"'|                   => [:multi, [:static, '\"']],
      %q|'\\\"'|                 => [:multi, [:static, '\\"']],
      %q|"static#{dynamic}"|     => [:multi, [:static, 'static'], [:dynamic, 'dynamic']],
    }.each do |code, expected|
      it "should split #{code}" do
        actual = @filter.call([:dynamic, code])
        actual.should.equal expected
      end
    end

    describe '.compile' do
      it 'should raise CompileError for non-string literals' do
        lambda { Temple::Filters::StringSplitter.compile('1') }.
          should.raise(Temple::FilterError)
      end

      it 'should compile strings quoted with parenthesis' do
        tokens = Temple::Filters::StringSplitter.compile('%Q(href("#{1 + 1}");)')
        tokens.should.equal [[:static, "href(\""], [:dynamic, "1 + 1"], [:static, "\");"]]
      end
    end
  end
end
