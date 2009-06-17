# See SexpQueryBuilder.m
class SexpPath::Matcher::Pattern < SexpPath::Matcher::Base
  attr_reader :pattern
  
  # Create a Patten matcher which will match any atom that either matches the input +pattern+.
  def initialize(pattern)
    @pattern = pattern
  end

  # Satisfied if +o+ is an atom, and +o+ matches +pattern+
  def satisfy?(o, data={})
    return nil unless !o.is_a?(Sexp) && o.to_s =~ pattern

    capture_match o, data
  end

  def inspect
    "m(#{pattern.inspect})"
  end
end