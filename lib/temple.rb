module Temple
  VERSION = "0.1.3"

  autoload :Generators, 'temple/generators'
  autoload :Engine,     'temple/engine'
  autoload :Utils,      'temple/utils'
  autoload :Mixins,     'temple/mixins'

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
    autoload :Debugger,       'temple/filters/debugger'
  end

  module HTML
    autoload :Fast,           'temple/html/fast'
  end
end
