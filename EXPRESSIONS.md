The Core Abstraction
--------------------

The core abstraction is what every template evetually should be compiled
to. Currently it consists of four essential and two convenient types:
multi, static, dynamic, code, newline and capture.

When compiling, there's two different strings we'll have to think about.
First we have the generated code. This is what your engine (from Temple's
point of view) spits out. If you construct this carefully enough, you can
make exceptions report correct line numbers, which is very convenient.

Then there's the result. This is what your engine (from the user's point
of view) spits out. It's what happens if you evaluate the generated code.

### [:multi, *sexp]

Multi is what glues everything together. It's simply a sexp which combines
several others sexps:

    [:multi,
      [:static, "Hello "],
      [:dynamic, "@world"]]

### [:static, string]

Static indicates that the given string should be appended to the result.

Example:

    [:static, "Hello World"]
is the same as:
    _buf << "Hello World"

    [:static, "Hello \n World"]
is the same as
    _buf << "Hello\nWorld"

### [:dynamic, ruby]

Dynamic indicates that the given Ruby code should be evaluated and then
appended to the result.

The Ruby code must be a complete expression in the sense that you can pass
it to eval() and it would not raise SyntaxError.

### [:code, ruby]

Code indicates that the given Ruby code should be evaluated, and may
change the control flow. Any \n causes a newline in the generated code.

### [:newline]

Newline causes a newline in the generated code, but not in the result.

### [:capture, variable_name, sexp]

Evaluates the Sexp using the rules above, but instead of appending to the
result, it sets the content to the variable given.

Example:

    [:multi,
      [:static, "Some content"],
      [:capture, "foo", [:static, "More content"]],
      [:dynamic, "foo.downcase"]]
is the same as:
    _buf << "Some content"
    foo = "More content"
    _buf << foo.downcase

Control flow abstraction
------------------------

Control flow abstractions can be used to write common ruby control flow constructs.
These expressions are compiled to [:code, ruby] by Temple::Filters::ControlFlow

### [:if, condition, if-sexp, optional-else-sexp]

Example:

    [:if,
     "1+1 == 2",
     [:static, "Yes"],
     [:static, "No"]]
is the same as:
    if 1+1 == 2
      _buf << "Yes"
    else
      _buf << "No"
    end

### [:block, ruby, sexp]

Example:

    [:block,
     '10.times do',
     [:static, 'Hello']]
is the same as:
    10.times do
      _buf << 'Hello'
    end

### [:case, argument, [condition, sexp], [condition, sexp], ...]

Example:

    [:case,
     'value',
     ["1",   "value is 1"],
     ["2",   "value is 2"],
     [:else, "don't know"]]
is the same as:
    case value
    when 1
      _buf << "value is 1"
    when 2
      _buf << "value is 2"
    else
      _buf << "don't know"
    end

### [:cond, [condition, sexp], [condition, sexp], ...]

    [:cond,
     ["a",   "a is true"],
     ["b",   "b is true"],
     [:else, "a and b are false"]]
is the same as:
    case
    when a
      _buf << "a is true"
    when b
      _buf << "b is true"
    else
      _buf << "a and b are false"
    end

Escape abstraction
------------------

### [:escape, bool, sexp]

HTML abstraction
----------------

### [:html, :doctype, string]

### [:html, :comment, sexp]

### [:html, :tag, identifier, attributes, closed-bool, sexp]

### [:html, :attrs, attributes]

### [:html, :attr, identifier, sexp]
