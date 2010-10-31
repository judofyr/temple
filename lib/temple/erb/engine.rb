module Temple
  module ERB
    class Engine < Temple::Engine
      use Temple::ERB::Parser, :auto_escape
      use Temple::ERB::Trimming, :trim_mode
      filter :EscapeHTML, :use_html_safe
      filter :MultiFlattener
      filter :StaticMerger
      filter :DynamicInliner
      generator :ArrayBuffer
    end
  end
end
