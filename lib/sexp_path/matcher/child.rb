class SexpPath::Matcher::Child < SexpPath::Matcher::Base
  attr_reader :child
  def initialize(child)
    @child = child
  end

  def satisfy?(o, data={})
    if child.satisfy?(o,data)
      capture_match o, data
    elsif o.is_a? Sexp
      o.search_each(child,data) do 
        return capture_match(o, data)
      end
    end
  end

  def inspect
    "child(#{child.inspect})"
  end
end