require 'spec_helper'
require 'tilt/erubi'

describe Temple::ERB::Engine do
  it 'should compile erb' do
    src = %q{
%% hi
= hello
<% 3.times do |n| %>
* <%= n %>
<% end %>
}

    expect(erb(src)).to eq(erubi(src))
  end

  it 'should recognize comments' do
    src = %q{
hello
  <%# comment -- ignored -- useful in testing %>
world}

    expect(erb(src)).to eq(erubi(src))
  end

  it 'should recognize <%% and %%>' do
    src = %q{
<%%
<% if true %>
  %%>
<% end %>
}

    expect(erb(src)).to eq("\n<%\n  %>\n")
  end

  it 'should escape automatically' do
    src = '<%== "<" %>'
    ans = '&lt;'
    expect(erb(src)).to eq(ans)
  end

  it 'should support = to disable automatic escape' do
    src = '<%= "<" %>'
    ans = '<'
    expect(erb(src)).to eq(ans)
  end

  it 'should support trim mode' do
    src = %q{
%% hi
= hello
<% 3.times do |n| %>
* <%= n %>
<% end %>
}

    expect(erb(src, trim: true)).to eq(erubi(src, trim: true))
    expect(erb(src, trim: false)).to eq(erubi(src, trim: false))
  end
end
