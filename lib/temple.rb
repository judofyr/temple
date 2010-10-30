require 'temple/version'

module Temple
  autoload :Generators,       'temple/generators'
  autoload :Engine,           'temple/engine'
  autoload :Utils,            'temple/utils'
  autoload :Mixins,           'temple/mixins'

  module Engines
    autoload :ERB,            'temple/engines/erb'
  end

  module Parsers
    autoload :ERB,            'temple/parsers/erb'
  end

  module Filters
    autoload :Filter,         'temple/filters/filter'
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
