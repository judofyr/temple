module Temple
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip.split('.').map{|i|i.to_i}
  
  autoload :Core,       'temple/core'
  autoload :Engine,     'temple/engine'
  autoload :Generator,  'temple/generator'
  
  module Parsers
    autoload :ERB,      'temple/parsers/erb'
    autoload :Mustache, 'temple/parsers/mustache'
  end
  
  module Filters
    autoload :Mustache,       'temple/filters/mustache'
    autoload :StaticMerger,   'temple/filters/static_merger'
    autoload :DynamicInliner, 'temple/filters/dynamic_inliner'
    autoload :Escapable,      'temple/filters/escapable'
  end
end
