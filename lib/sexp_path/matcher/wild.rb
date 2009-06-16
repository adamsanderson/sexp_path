class SexpPath::Matcher::Wild < SexpPath::Matcher::Base
  def satisfy?(o, data={})
    capture_match o, data
  end

  def inspect
    "wild"
  end
end