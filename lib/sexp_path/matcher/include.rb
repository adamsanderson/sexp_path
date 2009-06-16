class SexpPath::Matcher::Include < SexpPath::Matcher::Base
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def satisfy?(o, data={})
    if o.is_a? Sexp
      return nil unless o.any?{|c| value.is_a?(Sexp) ? value.satisfy?(c, data) : value == c}
    end
  
    capture_match o, data
  end

  def inspect
    "include(#{value.inspect})"
  end
end