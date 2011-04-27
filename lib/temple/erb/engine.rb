module Temple
  module ERB
    class Engine < Temple::Engine
      use Temple::ERB::Parser, :auto_escape
      filter :Escapable, :use_html_safe
      use Temple::ERB::Trimming, :trim_mode
      filter :MultiFlattener
      filter :StaticMerger
      filter :DynamicInliner
      generator :ArrayBuffer
    end
  end
end
