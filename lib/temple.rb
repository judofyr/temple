module Temple
  VERSION = "0.1.3"

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
    autoload :BasicFilter,    'temple/filters/basic_filter'
    autoload :MultiFlattener, 'temple/filters/multi_flattener'
    autoload :StaticMerger,   'temple/filters/static_merger'
    autoload :DynamicInliner, 'temple/filters/dynamic_inliner'
    autoload :EscapeHTML,     'temple/filters/escape_html'
  end

  module HTML
    autoload :Fast,           'temple/html/fast'
  end
end
