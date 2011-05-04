module Temple
  # Temple expression grammar
  # @api public
  module Grammar
    extend Mixins::GrammarDSL

    Expression <<
      # Core expressions
      [:multi, 'Expression*']                  |
      [:static, String]                        |
      [:dynamic, String]                       |
      [:code, String]                          |
      [:capture, String, Expression]           |
      [:newline]                               |
      # Control flow expressions
      [:if, String, Expression, 'Expression?'] |
      [:block, String, Expression]             |
      [:case, String, 'Case*']                 |
      [:cond, 'Case*']                         |
      # Escape expression
      [:escape, Bool, Expression]              |
      # HTML expressions
      [:html, :doctype, String]                |
      [:html, :comment, Expression]            |
      [:html, :tag, HTMLIdentifier, HTMLAttrs, 'Expression?']

    EmptyExp <<
      [:newline] | [:multi, 'EmptyExp*']

    HTMLAttrs <<
      Expression | [:html, :attrs, 'HTMLAttr*']

    HTMLAttr <<
      [:html, :attr, HTMLIdentifier, Expression]

    HTMLIdentifier <<
      Symbol | String

    Case <<
      [Condition, 'Expression*']

    Condition <<
      String | :else

    Bool <<
      true | false

  end
end
