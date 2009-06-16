class SexpPath::Matcher::Any < SexpPath::Matcher::Base
  attr_reader :options
  def initialize(*options)
    @options = options
  end

  def satisfy?(o, data={})
    return nil unless options.any?{|exp| exp.is_a?(Sexp) ? exp.satisfy?(o, data) : exp == o}
  
    capture_match o, data
  end

  def inspect
    options.map{|o| o.inspect}.join(' | ')
  end
end