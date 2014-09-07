module Temple
  class HtmlSafe < String
    def html_safe?; true end
    def html_safe;  self end
    def to_s;       self end
  end
end

class Object
  def html_safe?; false end
end

class Numeric
  def html_safe?; true end
end

class String
  def html_safe
    Temple::HtmlSafe.new(self)
  end
end
