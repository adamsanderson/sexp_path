class SexpPath::Matcher::Type < SexpPath::Matcher::Base
  attr_reader :sexp_type
  def initialize(type)
    @sexp_type = type
  end

  def satisfy?(o, data={})
    return nil unless o.is_a?(Sexp) && o.sexp_type == sexp_type
  
    capture_match o, data
  end

  def inspect
    "t(#{sexp_type.inspect})"
  end
end