module Temple
  module GrammarDSL
    class Rule
      def initialize(grammar)
        @grammar = grammar
      end

      def |(rule)
        Or.new(@grammar, self, rule)
      end

      def match(exp, &block)
        false
      end

      def copy_to(grammar)
        copy = dup.instance_eval { @grammar = grammar; self }
        copy.after_copy(self) if copy.respond_to?(:after_copy)
        copy
      end
    end

    class Or < Rule
      def initialize(grammar, *children)
        super(grammar)
        @children = children.map {|rule| @grammar.Rule(rule) }
      end

      def <<(rule)
        @children << @grammar.Rule(rule)
        self
      end

      alias | <<

      def match(exp, &block)
        @children.any? {|rule| rule.match(exp, &block) }
      end

      def after_copy(source)
        @children = @children.map do |child|
          child == source ? self : child.copy_to(@grammar)
        end
      end
    end

    class Root < Or
      def initialize(grammar, name)
        super(grammar)
        @name = name.to_sym
      end

      def match(exp)
        success = super
        yield(@name, exp, success) if block_given?
        success
      end

      def validate!(exp)
        require 'pp'
        error = nil
        match(exp) do |rule, subexp, success|
          error ||= PP.pp(subexp, "#{@grammar}::#{rule} did not match\n") unless success
        end || raise(InvalidExpression, error)
      end

      def copy_to(grammar)
        grammar.const_defined?(@name) ? grammar.const_get(@name) : super
      end

      def after_copy(source)
        @grammar.const_set(@name, self)
        super
      end
    end

    class Element < Or
      def initialize(grammar, rule)
        super(grammar)
        @rule = grammar.Rule(rule)
      end

      def match(exp, &block)
        return false if exp.empty?
        head, *tail = exp
        @rule.match(head, &block) && super(tail, &block)
      end

      def after_copy(source)
        super
        @rule = @rule.copy_to(@grammar)
      end
    end

    class Value < Rule
      def initialize(grammar, value)
        super(grammar)
        @value = value
      end

      def match(value)
        @value === value
      end
    end

    def extended(mod)
      mod.extend GrammarDSL
      constants.each do |name|
        const_get(name).copy_to(mod) if Rule === const_get(name)
      end
    end

    def match?(exp)
      const_get(:Expression).match(exp)
    end

    def validate!(exp)
      const_get(:Expression).validate!(exp)
    end

    alias === match?
    alias =~ match?

    def Value(value)
      Value.new(self, value)
    end

    def Rule(rule)
      case rule
      when Rule
        rule
      when Symbol, Class, true, false
        Value(rule)
      when Array
        start = Or.new(self)
        curr = [start]
        rule.each do |elem|
          case elem
          when /^(.*)\*$/
            elem = Element.new(self, const_get($1))
            curr << elem
            curr.each {|c| c << elem }
          when /^(.*)\?$/
            elem = Element.new(self, const_get($1))
            curr.each {|c| c << elem }
            curr << elem
          else
            elem = Element.new(self, elem)
            curr.each {|c| c << elem }
            curr = [elem]
          end
        end
        elem = Value([])
        curr.each {|c| c << elem }
        start
      else
        raise "Invalid grammar rule '#{rule.inspect}'"
      end
    end

    def const_missing(name)
      const_set(name, Root.new(self, name))
    end
  end
end
