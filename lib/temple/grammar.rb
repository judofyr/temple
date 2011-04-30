module Temple
  module Grammar
    extend GrammarDSL

    Expression <<
      # Core expressions
      [:multi, 'Expression*']                                 |
      [:static, String]                                       |
      [:dynamic, String]                                      |
      [:code, String]                                         |
      [:capture, String, 'Expression']                        |
      [:newline]                                              |
      # Control flow expressions
      [:if, String, 'Expression', 'Expression?']              |
      [:block, String, 'Expression']                          |
      [:case, String, 'Case*']                                |
      [:cond, 'Case*']                                        |
      # Escape expression
      [:escape, 'Bool', 'Expression']                         |
      # HTML expressions
      [:html, :doctype, String]                               |
      [:html, :comment, 'Expression']                         |
      [:html, :tag, String, 'HTMLAttrs', true,  'EmptyExp']   |
      [:html, :tag, String, 'HTMLAttrs', false, 'Expression']

    EmptyExp  << [:newline] | [:multi, 'EmptyExp*']
    HTMLAttrs << 'Expression' | [:html, :attrs, 'HTMLAttr*']
    HTMLAttr  << [:html, :attr, Rule(Symbol) | String, 'Expression']
    Case      << [String, 'Expression*']
    Bool      << true | false
  end
end
