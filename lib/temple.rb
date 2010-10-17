module Temple
  VERSION = "0.1.1"
  
  autoload :Core,       'temple/core'
  autoload :Engine,     'temple/engine'
  autoload :Generator,  'temple/generator'
  autoload :Utils,      'temple/utils'
  
  module Engines
    autoload :ERB,      'temple/engines/erb'
  end
  
  module Parsers
    autoload :ERB,      'temple/parsers/erb'
  end
  
  module Filters
    autoload :MultiFlattener, 'temple/filters/multi_flattener'
    autoload :StaticMerger,   'temple/filters/static_merger'
    autoload :DynamicInliner, 'temple/filters/dynamic_inliner'
  end

  module HTML
    autoload :Fast,           'temple/html/fast'
  end
end
