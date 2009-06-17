# See SexpQueryBuilder.t
class SexpPath::Matcher::Type < SexpPath::Matcher::Base
  attr_reader :sexp_type
  
  # Creates a Matcher which will match any Sexp who's type is +type+, where a type is
  # the first element in the Sexp.
  def initialize(type)
    @sexp_type = type
  end

  # Satisfied if the sexp_type of +o+ is +type+.
  def satisfy?(o, data={})
    return nil unless o.is_a?(Sexp) && o.sexp_type == sexp_type
  
    capture_match o, data
  end

  def inspect
    "t(#{sexp_type.inspect})"
  end
end