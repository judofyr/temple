module Temple
  module Filters
    # A Mustache filter which compiles Mustache-nodes into Core and Escapable.
    # It's currently built for the Interpolation generator, but works with the
    # others too.
    class Mustache
      def initialize
        @tmpid = 0
      end
      
      def tmpid
        @tmpid += 1
      end
      
      def compile(exp)
        case exp.first
        when :mustache
          send("on_#{exp[1]}", *exp[2..-1])
        when :multi
          [:multi, *exp[1..-1].map { |e| compile(e) }]
        else
          exp
        end
      end
      
      def on_evar(name)
        exp = on_var(name)
        exp[1] = [:escape, exp[1]]
        exp
      end
      
      def on_var(name)
        [:dynamic, "ctx[#{name.inspect}]"]
      end
      
      def on_section(name, content)
        res = [:multi]
        code = compile(content)
        ctxtmp = "ctx#{tmpid}"
        
        block = <<-EOF
        if v = ctx[#{name.inspect}]
          v = [v] if v.is_a?(Hash) # shortcut when passed a single hash
          if v.respond_to?(:each)
            #{ctxtmp} = ctx.dup
            begin
              r = v.map { |h| ctx.update(h); CODE }.join
            rescue TypeError => e
              raise TypeError,
                "All elements in {{#{name.to_s}}} are not hashes!"
            end
            ctx.replace(#{ctxtmp})
            r
          else
            CODE
          end
        end
        EOF
        
        block.split("CODE").each do |str|
          res << [:block, str]
          res << code
        end
        
        res.pop
        res
      end
    end
  end
end