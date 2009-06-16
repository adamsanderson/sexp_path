class SexpPath::Matcher::Pattern < SexpPath::Matcher::Base
  attr_reader :pattern
  def initialize(pattern)
    @pattern = pattern
  end

  def satisfy?(o, data={})
    return nil unless !o.is_a?(Sexp) && o.to_s =~ pattern

    capture_match o, data
  end

  def inspect
    "m(#{pattern.inspect})"
  end
end