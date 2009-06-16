class SexpPath::Matcher::Atom < SexpPath::Matcher::Base
  def satisfy?(o, data={})
    return nil if o.is_a? Sexp
  
    capture_match o, data
  end

  def inspect
    "atom"
  end
end