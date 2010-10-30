require 'helper'
require 'erb'

NormalERB = ::ERB
TempleERB = Temple::Engines::ERB

class ERBTestError < RuntimeError; end
