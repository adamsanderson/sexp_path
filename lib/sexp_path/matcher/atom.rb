# See SexpQueryBuilder.atom
class SexpPath::Matcher::Atom < SexpPath::Matcher::Base
  # Satisfied when +o+ is an atom (anything that is not an S-Expression)
  def satisfy?(o, data={})
    return nil if o.is_a? Sexp
  
    capture_match o, data
  end
  
  # Prints as +atom+
  def inspect
    "atom"
  end
end