# This is the base class for all Sexp matchers.
#
# A matcher should implement the following methods:
#
# * satisfy?
# * inspect
#
# +satisfy?+ determines whether the matcher matches a given input,
# and +inspect+ will print the matcher nicely in a user's console.
#
# The base matcher is created with the SexpQueryBuilder as follows
#   Q?{ s() }
class SexpPath::Matcher::Base < Sexp
  # Combines the Matcher with another Matcher, the resulting one will
  # be satisfied if either Matcher would be satisfied.
  # 
  # Example:
  #   s(:a) | s(:b) 
  def | o
    SexpPath::Matcher::Any.new(self, o)
  end
  
  # Combines the Matcher with another Matcher, the resulting one will
  # be satisfied only if both Matchers would be satisfied.
  # 
  # Example:
  #   t(:a) & include(:b)
  def & o
    SexpPath::Matcher::All.new(self, o)
  end
  
  # Returns a Matcher that matches whenever this Matcher would not have matched
  # 
  # Example:
  #   -s(:a)
  def -@
    SexpPath::Matcher::Not.new(self)
  end
  
  # Returns a Matcher that matches if this has a sibling +o+
  # 
  # Example:
  #   s(:a) >> s(:b)
  def >> o
    SexpPath::Matcher::Sibling.new(self, o)
  end
  
  # Formats the matcher as:
  #   q(:a, :b)
  def inspect
    children = map{|e| e.inspect}.join(', ')
    "q(#{children})"
  end
end