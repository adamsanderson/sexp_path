class SexpPath::Matcher::Base < Sexp
  def | o
    SexpPath::Matcher::Any.new(self, o)
  end

  def & o
    SexpPath::Matcher::All.new(self, o)
  end
  
  def inspect
    children = map{|e| e.inspect}.join(', ')
    "q(#{children})"
  end
end