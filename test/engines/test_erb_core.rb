require 'engines/erb_helper'

shared 'erb core' do
  it 'should compile erb with different safe levels' do
    [nil, 0, 1, 2, 3].each do |safe|
      @erb.new("hello").result.should.equal "hello"

      @erb.new("hello", safe, 0).result.should.equal "hello"

      @erb.new("hello", safe, 1).result.should.equal "hello"

      @erb.new("hello", safe, 2).result.should.equal "hello"

      src = %q{
%% hi
= hello
<% 3.times do |n| %>
% n=0
* <%= n %>
<% end %>
}

      ans = %q{
%% hi
= hello

% n=0
* 0

% n=0
* 1

% n=0
* 2

}
    @erb.new(src).result.should.equal ans

    @erb.new(src, safe, 0).result.should.equal ans
    @erb.new(src, safe, '').result.should.equal ans

    ans = %q{
%% hi
= hello
% n=0
* 0% n=0
* 1% n=0
* 2
}

      @erb.new(src, safe, 1).result.should.equal ans.chomp
      @erb.new(src, safe, '>').result.should.equal ans.chomp

      ans  = %q{
%% hi
= hello
% n=0
* 0
% n=0
* 1
% n=0
* 2
}

      @erb.new(src, safe, 2).result.should.equal ans
      @erb.new(src, safe, '<>').result.should.equal ans

      ans = %q{
% hi
= hello

* 0

* 0

* 0

}
      @erb.new(src, safe, '%').result.should.equal ans

      ans = %q{
% hi
= hello
* 0* 0* 0
}
      @erb.new(src, safe, '%>').result.should.equal ans.chomp

      ans = %{
% hi
= hello
* 0
* 0
* 0
}

      @erb.new(src, safe, '%<>').result.should.equal ans
    end
  end

  it 'should support safe level 4' do
    @erb.new('<%=$SAFE%>', 4).result(TOPLEVEL_BINDING.taint).should.equal '4'
  end

  it 'should have #def_class' do
    foo = Class.new
    erb = @erb.new('hello')

    cls = erb.def_class
    cls.superclass.should.equal Object
    cls.new.should.respond_to('result')

    cls = erb.def_class(foo)
    cls.superclass.should.equal foo
    cls.new.should.respond_to('result')

    cls = erb.def_class(Object, 'erb')
    cls.superclass.should.equal Object
    cls.new.should.respond_to('erb')
  end

  it 'should support percent' do
    src = %q{
%n = 1
<%= n%>
}

    TempleERB.new(src, nil, '%').result.should.equal "\n1\n"

    src = %q{
<%
%>
}

    TempleERB.new(src, nil, '%').result.should.equal "\n\n"

    src = "<%\n%>"
    TempleERB.new(src, nil, '%').result.should.equal ""

    src = %q{
<%
n = 1
%><%= n%>
}
    TempleERB.new(src, nil, '%').result.should.equal "\n1\n"

    src = %q{
%n = 1
%% <% n = 2
n.times do |i|%>
%% %%><%%<%= i%><%
end%>
%%%
}
    ans = %q{
% 
% %%><%0
% %%><%1
%%
}
    TempleERB.new(src, nil, '%').result.should.equal ans
  end

  it 'should have #def_erb_method' do
    klass = Class.new
    klass.module_eval do
      extend ERB::DefMethod
      fname = File.join(File.dirname(File.expand_path(__FILE__)), 'hello.erb')
      def_erb_method('hello', fname)
    end
    klass.new.should.respond_to('hello')

    klass.new.should.not.respond_to('hello_world')
    erb = @erb.new('hello, world')
    klass.module_eval do
      def_erb_method('hello_world', erb)
    end
    klass.new.should.respond_to('hello_world')
  end

  it 'should support #def_method without filename' do
    klass = Class.new
    erb = TempleERB.new("<% raise ::ERBTestError %>")
    erb.filename = "test filename"
    klass.new.should.not.respond_to('my_error')
    erb.def_method(klass, 'my_error')
    lambda {
       klass.new.my_error
    }.should.raise(::ERBTestError).backtrace[0].should.match /\A\(ERB\):1\b/
  end

  it 'should support #def_method with filename' do
    klass = Class.new
    erb = TempleERB.new("<% raise ::ERBTestError %>")
    erb.filename = "test filename"
    klass.new.should.not.respond_to('my_error')
    erb.def_method(klass, 'my_error', 'test fname')
    lambda {
       klass.new.my_error
    }.should.raise(::ERBTestError).backtrace[0].should.match /\Atest fname:1\b/
  end

  it 'should escape' do
    src = %q{
1.<%% : <%="<%%"%>
2.%%> : <%="%%>"%>
3.
% x = "foo"
<%=x%>
4.
%% print "foo"
5.
%% <%="foo"%>
6.<%="
% print 'foo'
"%>
7.<%="
%% print 'foo'
"%>
}
    ans = %q{
1.<% : <%%
2.%%> : %>
3.
foo
4.
% print "foo"
5.
% foo
6.
% print 'foo'

7.
%% print 'foo'

}
    TempleERB.new(src, nil, '%').result.should.equal ans
  end

  it 'should keep lineno' do
    src = %q{
Hello, 
% x = "World"
<%= x%>
% raise("lineno")
}

    erb = TempleERB.new(src, nil, '%')
    lambda {
      erb.result
    }.should.raise.backtrace[0].should.match /\A\(erb\):5\b/

    src = %q{
%>
Hello, 
<% x = "World%%>
"%>
<%= x%>
}

    ans = %q{
%>Hello, 
World%>
}
    TempleERB.new(src, nil, '>').result.should.equal ans

    ans = %q{
%>
Hello, 

World%>
}
    TempleERB.new(src, nil, '<>').result.should.equal ans

    ans = %q{
%>
Hello, 

World%>

}
    TempleERB.new(src).result.should.equal ans

   src = %q{
Hello, 
<% x = "World%%>
"%>
<%= x%>
<% raise("lineno") %>
}

    erb = TempleERB.new(src)
    lambda {
      erb.result
    }.should.raise.backtrace[0].should.match /\A\(erb\):6\b/

    erb = TempleERB.new(src, nil, '>')
    lambda {
      erb.result
    }.should.raise.backtrace[0].should.match /\A\(erb\):6\b/

    erb = TempleERB.new(src, nil, '<>')
    lambda {
      erb.result
    }.should.raise.backtrace[0].should.match /\A\(erb\):6\b/

    src = %q{
% y = 'Hello'
<%- x = "World%%>
"-%>
<%= x %><%- x = nil -%> 
<% raise("lineno") %>
}

    erb = TempleERB.new(src, nil, '-')
    lambda {
      erb.result
    }.should.raise.backtrace[0].should.match /\A\(erb\):6\b/

    erb = TempleERB.new(src, nil, '%-')
    lambda {
      erb.result
    }.should.raise.backtrace[0].should.match /\A\(erb\):6\b/
  end

  it 'should support explicit' do
    src = %q{
<% x = %w(hello world) -%>
NotSkip <%- y = x -%> NotSkip
<% x.each do |w| -%>
  <%- up = w.upcase -%>
  * <%= up %>
<% end -%>
 <%- z = nil -%> NotSkip <%- z = x %>
 <%- z.each do |w| -%>
   <%- down = w.downcase -%>
   * <%= down %>
   <%- up = w.upcase -%>
   * <%= up %>
 <%- end -%>
KeepNewLine <%- z = nil -%> 
}

    ans = %q{
NotSkip  NotSkip
  * HELLO
  * WORLD
 NotSkip 
   * hello
   * HELLO
   * world
   * WORLD
KeepNewLine  
}
   TempleERB.new(src, nil, '-').result.should.equal ans
   TempleERB.new(src, nil, '-%').result.should.equal ans
  end

  it 'should have #url_encode' do
    ERB::Util.url_encode("Programming Ruby:  The Pragmatic Programmer's Guide").should.equal \
    "Programming%20Ruby%3A%20%20The%20Pragmatic%20Programmer%27s%20Guide"

    if "".respond_to?(:force_encoding)
      ERB::Util.url_encode("\xA5\xB5\xA5\xF3\xA5\xD7\xA5\xEB".force_encoding("EUC-JP")).should.equal "%A5%B5%A5%F3%A5%D7%A5%EB"
    end
  end
end

describe 'erb core with string scan' do
  before do
    @erb = TempleERB
  end

  behaves_like 'erb core'
end

describe 'erb core without string scan' do
  before do
    @erb = TempleERB

    @save_map = ERB::Compiler::Scanner.instance_variable_get('@scanner_map')
    map = {[nil, false]=>ERB::Compiler::SimpleScanner}
    ERB::Compiler::Scanner.instance_variable_set('@scanner_map', map)
  end

  after do
    ERB::Compiler::Scanner.instance_variable_set('@scanner_map', @save_map)
  end

  behaves_like 'erb core'
end
