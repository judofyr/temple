module Temple
  module Filters
    # A Mustache filter which compiles Mustache-nodes into Core and Escapable.
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
        
        src = <<-EOF
          if v = ctx[#{name.inspect}]
            v = [v] if v.is_a?(Hash)
            if v.respond_to?(:each)
              #{ctxtmp} = ctx.dup
              begin
                r = v.each do |h|
                  ctx.update(h)
                  CODE
                end
              rescue TypeError => e
                raise TypeError, "All elements in {{#{name.to_s}}} are not hashes!"
              end
              ctx.replace(#{ctxtmp})
            else
              CODE
            end
          end
        EOF
        
        res = src.split("\n").map do |line|
          line =~ /CODE/ ? code : [:block, line.strip]
        end
        
        [:multi, *res]
      end
    end
  end
end