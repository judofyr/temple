module Temple
  module Mixins
    module EngineDSL
      def append(*args, &block)
        chain << element(args, block)
      end

      def prepend(*args, &block)
        chain.unshift(element(args, block))
      end

      def remove(name)
        found = false
        chain.reject! do |i|
          equal = i.first == name
          found = true if equal
          equal
        end
        raise "#{name} not found" unless found
      end

      alias use append

      def before(name, *args, &block)
        name = Class === name ? name.name.to_sym : name
        raise(ArgumentError, 'First argument must be Class or Symbol') unless Symbol === name
        e = element(args, block)
        found, i = false, 0
        while i < chain.size
          if chain[i].first == name
            found = true
            chain.insert(i, e)
            i += 2
          else
            i += 1
          end
        end
        raise "#{name} not found" unless found
      end

      def after(name, *args, &block)
        name = Class === name ? name.name.to_sym : name
        raise(ArgumentError, 'First argument must be Class or Symbol') unless Symbol === name
        e = element(args, block)
        found, i = false, 0
        while i < chain.size
          if chain[i].first == name
            found = true
            i += 1
            chain.insert(i, e)
          end
          i += 1
        end
        raise "#{name} not found" unless found
      end

      def replace(name, *args, &block)
        name = Class === name ? name.name.to_sym : name
        raise(ArgumentError, 'First argument must be Class or Symbol') unless Symbol === name
        e = element(args, block)
        found = false
        chain.each_with_index do |c, i|
          if c.first == name
            found = true
            chain[i] = e
          end
        end
        raise "#{name} not found" unless found
      end

      def filter(name, *options, &block)
        use(name, Temple::Filters.const_get(name), *options, &block)
      end

      def generator(name, *options, &block)
        use(name, Temple::Generators.const_get(name), *options, &block)
      end

      private

      def element(args, block)
        name = args.shift
        if Class === name
          filter = name
          name = filter.name.to_sym
        end
        raise(ArgumentError, 'First argument must be Class or Symbol') unless Symbol === name

        if block
          raise(ArgumentError, 'Class and block argument are not allowed at the same time') if filter
          filter = block
        end

        filter ||= args.shift

        case filter
        when Proc
          # Proc or block argument
          # The proc is converted to a method of the engine class.
          # The proc can then access the option hash of the engine.
          raise(ArgumentError, 'Too many arguments') unless args.empty?
          raise(ArgumentError, 'Proc or blocks must have arity 1') unless filter.arity == 1
          method_name = "FILTER #{name}"
          if Class === self
            define_method(method_name, &filter)
            [name, instance_method(method_name)]
          else
            (class << self; self; end).class_eval { define_method(method_name, &filter) }
            [name, method(method_name)]
          end
        when Class
          # Class argument (e.g Filter class)
          # The options are passed to the classes constructor.
          local_options = Hash === args.last ? args.pop : nil
          raise(ArgumentError, 'Only symbols allowed in option filter') unless args.all? {|o| Symbol === o }
          [name, filter, args, local_options]
        else
          # Other callable argument (e.g. Object of class which implements #call or Method)
          # The callable has no access to the option hash of the engine.
          raise(ArgumentError, 'Class or callable argument is required') unless filter.respond_to?(:call)
          [name, filter]
        end
      end
    end

    module CoreDispatcher
      def on_multi(*exps)
        [:multi, *exps.map {|exp| compile(exp) }]
      end

      def on_capture(name, exp)
        [:capture, name, compile(exp)]
      end

      def on_escape(flag, exp)
        [:escape, flag, compile(exp)]
      end

      def on_if(condition, *cases)
        [:if, condition, *cases.compact.map {|e| compile(e) }]
      end

      def on_loop(code, content)
        [:loop, code, compile(content)]
      end
    end

    module Dispatcher
      include CoreDispatcher

      def self.included(base)
        base.class_eval { extend ClassMethods }
      end

      def call(exp)
        compile(exp)
      end

      def compile(exp)
        type, *args = exp
        if respond_to?("on_#{type}")
          send("on_#{type}", *args)
        else
          exp
        end
      end

      module ClassMethods
        def temple_dispatch(*bases)
          bases.each do |base|
            class_eval %{def on_#{base}(type, *args)
              if respond_to?("on_" #{base.to_s.inspect} "_\#{type}")
                send("on_" #{base.to_s.inspect} "_\#{type}", *args)
              else
                [:#{base}, type, *args]
              end
            end}
          end
        end
      end
    end

    module DefaultOptions
      def set_default_options(options)
        default_options.update(options)
      end

      def default_options
        @default_options ||= Utils::MutableHash.new(superclass.respond_to?(:default_options) ?
                                                    superclass.default_options : nil)
      end
    end

    module Options
      def self.included(base)
        base.class_eval { extend DefaultOptions }
      end

      attr_reader :options

      def initialize(options = {})
        @options = Utils::ImmutableHash.new(options, self.class.default_options)
      end
    end

    module Template
      include DefaultOptions

      def engine(engine = nil)
        default_options[:engine] = engine if engine
        default_options[:engine]
      end

      def build_engine(*options)
        raise 'No engine configured' unless engine
        options << default_options
        engine.new(Utils::ImmutableHash.new(*options)) do |e|
          chain.each {|block| e.instance_eval(&block) }
        end
      end

      def chain(&block)
        chain = (default_options[:chain] ||= [])
        chain << block if block
        chain
      end
    end
  end
end
