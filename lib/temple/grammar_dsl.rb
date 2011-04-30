module Temple
  module GrammarDSL
    class Rule
      include GrammarDSL

      def |(rule)
        Or.new(self, rule)
      end

      def match(grammar, exp, &block)
        false
      end

      protected

    end

    class Or < Rule
      def initialize(*rules)
        @rules = rules.map {|r| Rule(r) }
      end

      def <<(rule)
        @rules << Rule(rule)
        self
      end

      alias | <<

      def match(grammar, exp, &block)
        @rules.any? {|r| r.match(grammar, exp, &block) }
      end
    end

    class Root < Or
      attr_reader :name, :rules

      def initialize(name, *rules)
        super(*rules)
        @name = name.to_sym
      end

      def match(grammar, exp)
        success = super
        yield(@name, exp, success) if block_given?
        success
      end

      def validate!(grammar, exp)
        require 'pp'
        error = nil
        match(grammar, exp) do |rule, subexp, success|
          if !success && rule == :Expression
            error = PP.pp(subexp, "#{grammar} - No match found\n")
            break
          end
        end
        raise InvalidExpression, error if error
      end
    end

    class Name < Rule
      def initialize(name)
        @name = name
      end

      def match(grammar, exp, &block)
        raise "Rule not found '#{@name}'" unless grammar.const_defined?(@name)
        rule = grammar.const_get(@name)
        raise "Invalid rule '#{@name}'" unless Rule === rule
        rule.match(grammar, exp, &block)
      end
    end

    class Element < Or
      def initialize(rule)
        super()
        @rule = Rule(rule)
      end

      def match(grammar, exp, &block)
        return false if exp.empty?
        head, *tail = exp
        @rule.match(grammar, head, &block) && super(grammar, tail, &block)
      end
    end

    class Value < Rule
      def initialize(value)
        @value = value
      end

      def match(grammar, value)
        @value === value
      end
    end

    def extended(mod)
      mod.extend GrammarDSL
      constants.each do |name|
        mod.const_set(name, const_get(name)) if Rule === const_get(name)
      end
    end

    def match?(exp)
      const_get(:Expression).match(self, exp)
    end

    def validate!(exp)
      const_get(:Expression).validate!(self, exp)
    end

    alias === match?
    alias =~ match?

    def Value(value)
      Value.new(value)
    end

    def Rule(rule)
      case rule
      when Rule
        rule
      when Symbol, Class, true, false
        Value(rule)
      when Array
        start = Or.new
        curr = [start]
        rule.each do |elem|
          case elem
          when /^(.*)\*$/
            elem = Element.new($1)
            curr << elem
            curr.each {|c| c << elem }
          when /^(.*)\?$/
            elem = Element.new($1)
            curr.each {|c| c << elem }
            curr << elem
          else
            elem = Element.new(elem)
            curr.each {|c| c << elem }
            curr = [elem]
          end
        end
        elem = Value([])
        curr.each {|c| c << elem }
        start
      when String
        Name.new(rule)
      else
        raise "Invalid grammar rule '#{rule.inspect}'"
      end
    end

    def const_missing(name)
      const_set(name, Root.new(name))
    end
  end
end
