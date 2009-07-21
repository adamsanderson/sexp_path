# See SexpQueryBuilder.not
class SexpPath::Matcher::Not < SexpPath::Matcher::Base
  attr_reader :value
  
  # Creates a Matcher which will match any Sexp that does not match the +value+
  def initialize(value)
    @value = value
  end
  
  # Satisfied if a +o+ does not match the +value+
  def satisfy?(o, data={})
    return nil if value.is_a?(Sexp) ? value.satisfy?(o, data) : value == o

    capture_match o, {}
  end

  def inspect
    "is_not(#{value.inspect})"
  end
end