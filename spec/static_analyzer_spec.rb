require 'spec_helper'

describe Temple::StaticAnalyzer do
  describe '.available?' do
    it 'should return true if its dependency is available' do
      expect(Temple::StaticAnalyzer.available?).to eq(defined?(Ripper) && Ripper.respond_to?(:lex))
    end
  end

  if Temple::StaticAnalyzer.available?
    describe '.static?' do
      it 'should return true if given Ruby expression is static' do
        ['true', 'false', '"hello world"', "[1, { 2 => 3 }]", "[\n1,\n]"].each do |exp|
          expect(Temple::StaticAnalyzer.static?(exp)).to eq(true)
        end
      end

      it 'should return false if given Ruby expression is dynamic' do
        ['1 + 2', 'variable', 'method_call(a)', 'CONSTANT'].each do |exp|
          expect(Temple::StaticAnalyzer.static?(exp)).to eq(false)
        end
      end
    end

    describe '.syntax_error?' do
      it 'should return false if given Ruby expression is valid' do
        ['Foo.bar.baz { |c| c.d! }', '{ foo: bar }'].each do |exp|
          expect(Temple::StaticAnalyzer.syntax_error?(exp)).to eq(false)
        end
      end

      it 'should return true if given Ruby expression is invalid' do
        ['Foo.bar.baz { |c| c.d! ', ' foo: bar '].each do |exp|
          expect(Temple::StaticAnalyzer.syntax_error?(exp)).to eq(true)
        end
      end
    end
  end
end
