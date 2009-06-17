# See SexpQueryBuilder.all
class SexpPath::Matcher::All < SexpPath::Matcher::Base
  attr_reader :options
  
  # Create an All matcher which will match all of the +options+.
  def initialize(*options)
    @options = options
  end
  
  # Satisfied when all sub expressions match +o+
  def satisfy?(o, data={})
    return nil unless options.all?{|exp| exp.is_a?(Sexp) ? exp.satisfy?(o, data) : exp == o}
  
    capture_match o, data
  end

  def inspect
    options.map{|o| o.inspect}.join(' & ')
  end
end