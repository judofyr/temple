module Temple
  module Engines
    class ERB < Engine
      parser :ERB, :auto_escape
      filter :TrimERB, :trim_mode
      filter :EscapeHTML, :use_html_safe
      filter :MultiFlattener
      filter :StaticMerger
      filter :DynamicInliner
      generator :ArrayBuffer
    end
  end
end
