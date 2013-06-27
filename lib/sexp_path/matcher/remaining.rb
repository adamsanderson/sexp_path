# See SexpQueryBuilder.___ 
#
class SexpPath::Matcher::Remaining < SexpPath::Matcher::Base  
  # Creates a Matcher which will match any remaining 
  # Defaults to matching the immediate following sibling.
  def initialize()

  end
  
  # Always satisfied once this is reached.  Think of it as a var arg.
  def satisfy?(o, data={})
    true
  end
  
  def inspect
    "___"
  end
  
end