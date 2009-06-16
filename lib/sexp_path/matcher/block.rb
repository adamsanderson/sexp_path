class SexpPath::Matcher::Block < SexpPath::Matcher::Base
  attr_reader :exp
  def initialize &block
    @exp = block
  end

  def satisfy?(o, data={})
    return nil unless @exp[o]
  
    capture_match o, data
  end

  def inspect
    "<custom>"
  end
end