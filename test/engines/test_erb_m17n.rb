# -*- coding: UTF-8 -*-
require 'engines/erb_helper'

if "".respond_to?(:encoding)
  describe 'ERB M17N' do
    before do
      Temple::Engines::ERB.rock!
    end

    after do
      Temple::Engines::ERB.rock!
    end

    it 'should have correct result encoding' do
      erb = ERB.new("hello")
      erb.result.encoding.should.equal __ENCODING__

      erb = ERB.new("こんにちは".encode("EUC-JP"))
      erb.result.encoding.should.equal Encoding::EUC_JP

      erb = ERB.new("\xC4\xE3\xBA\xC3".force_encoding("EUC-CN"))
      erb.result.encoding.should.equal Encoding::EUC_CN

      erb = ERB.new("γεια σας".encode("ISO-8859-7"))
      erb.result.encoding.should.equal Encoding::ISO_8859_7

      lambda {
        ERB.new("こんにちは".force_encoding("ISO-2022-JP")) # dummy encoding
      }.should.raise(ArgumentError)
    end

    it 'should generate magic comment' do
      erb = ERB.new("hello")
      erb.src.should.match /#coding:UTF-8/

      erb = ERB.new("hello".force_encoding("EUC-JP"))
      erb.src.should.match /#coding:EUC-JP/

      erb = ERB.new("hello".force_encoding("ISO-8859-9"))
      erb.src.should.match /#coding:ISO-8859-9/
    end

    it 'should have correct literal encoding' do
      erb = ERB.new("literal encoding is <%= 'hello'.encoding  %>")
      erb.result.should.match /literal encoding is UTF-8/

      erb = ERB.new("literal encoding is <%= 'こんにちは'.encoding  %>".encode("EUC-JP"))
      erb.result.should.match /literal encoding is EUC-JP/

      erb = ERB.new("literal encoding is <%= '\xC4\xE3\xBA\xC3'.encoding %>".force_encoding("EUC-CN"))
      erb.result.should.match /literal encoding is GB2312/
    end

    it 'should have correct __ENCODING__' do
      erb = ERB.new("__ENCODING__ is <%= __ENCODING__ %>")
      erb.result.should.match /__ENCODING__ is UTF-8/

      erb = ERB.new("__ENCODING__ is <%= __ENCODING__ %>".force_encoding("EUC-JP"))
      erb.result.should.match /__ENCODING__ is EUC-JP/

      erb = ERB.new("__ENCODING__ is <%= __ENCODING__ %>".force_encoding("Big5"))
      erb.result.should.match /__ENCODING__ is Big5/
    end

    it 'should recognize magic comment' do
      erb = ERB.new(<<-EOS.encode("EUC-KR"))
<%# -*- coding: EUC-KR -*- %>
안녕하세요
      EOS
      erb.src.should.match /#coding:EUC-KR/
      erb.result.encoding.should.equal Encoding::EUC_KR

      erb = ERB.new(<<-EOS.encode("EUC-KR").force_encoding("ASCII-8BIT"))
<%#-*- coding: EUC-KR -*-%>
안녕하세요
      EOS
      erb.src.should.match /#coding:EUC-KR/
      erb.result.encoding.should.equal Encoding::EUC_KR

      erb = ERB.new(<<-EOS.encode("EUC-KR").force_encoding("ASCII-8BIT"))
<%# vim: tabsize=8 encoding=EUC-KR shiftwidth=2 expandtab %>
안녕하세요
      EOS
      erb.src.should.match /#coding:EUC-KR/
      erb.result.encoding.should.equal Encoding::EUC_KR

      erb = ERB.new(<<-EOS.encode("EUC-KR").force_encoding("ASCII-8BIT"))
<%#coding:EUC-KR %>
안녕하세요
      EOS
      erb.src.should.match /#coding:EUC-KR/
      erb.result.encoding.should.equal Encoding::EUC_KR

      erb = ERB.new(<<-EOS.encode("EUC-KR").force_encoding("EUC-JP"))
<%#coding:EUC-KR %>
안녕하세요
      EOS
      erb.src.should.match /#coding:EUC-KR/
      erb.result.encoding.should.equal Encoding::EUC_KR
    end

    it 'should support method with encoding' do
      m = Module.new
      obj = Object.new
      obj.extend(m)

      erb = ERB.new(<<-EOS.encode("EUC-JP").force_encoding("ASCII-8BIT"))
<%#coding:EUC-JP %>
literal encoding is <%= 'こんにちは'.encoding %>
__ENCODING__ is <%= __ENCODING__ %>
    EOS
      erb.def_method(m, :m_from_magic_comment)

      result = obj.m_from_magic_comment
      erb.result.encoding.should.equal Encoding::EUC_JP
      erb.result.should.match /literal encoding is EUC-JP/
      erb.result.should.match /__ENCODING__ is EUC-JP/

      erb = ERB.new(<<-EOS.encode("EUC-KR"))
literal encoding is <%= '안녕하세요'.encoding %>
__ENCODING__ is <%= __ENCODING__ %>
EOS
      erb.def_method(m, :m_from_eval_encoding)
      result = obj.m_from_eval_encoding
      erb.result.encoding.should.equal Encoding::EUC_KR
      erb.result.should.match /literal encoding is EUC-KR/
      erb.result.should.match /__ENCODING__ is EUC-KR/
    end
  end
end

# vim:fileencoding=UTF-8
