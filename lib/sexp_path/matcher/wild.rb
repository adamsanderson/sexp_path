# See SexpQueryBuilder.wild and SexpQueryBuilder._
class SexpPath::Matcher::Wild < SexpPath::Matcher::Base
  
  # Matches any single element.
  def satisfy?(o, data={})
    capture_match o, data
  end

  def inspect
    "wild"
  end
end