require 'temple/version'

module Temple
  autoload :Generator,        'temple/generators'
  autoload :Generators,       'temple/generators'
  autoload :Engine,           'temple/engine'
  autoload :Utils,            'temple/utils'
  autoload :Mixins,           'temple/mixins'
  autoload :Filter,           'temple/filter'
  autoload :Templates,        'temple/templates'

  module ERB
    autoload :Engine,         'temple/erb/engine'
    autoload :Parser,         'temple/erb/parser'
    autoload :Trimming,       'temple/erb/trimming'
  end

  module Filters
    autoload :MultiFlattener, 'temple/filters/multi_flattener'
    autoload :StaticMerger,   'temple/filters/static_merger'
    autoload :DynamicInliner, 'temple/filters/dynamic_inliner'
    autoload :EscapeHTML,     'temple/filters/escape_html'
    autoload :Debugger,       'temple/filters/debugger'
  end

  module HTML
    autoload :Dispatcher,     'temple/html/dispatcher'
    autoload :Filter,         'temple/html/filter'
    autoload :Fast,           'temple/html/fast'
    autoload :Pretty,         'temple/html/pretty'
  end
end
