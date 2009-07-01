require 'parse_tree'

# See SexpQueryBuilder.wild and SexpQueryBuilder._
class SexpPath::Matcher::RubyFragment < SexpPath::Matcher::Base
  attr_reader :fragment
  attr_reader :fragment_sexp
  
  def initialize(fragment, lenient=true)
    initial_fragment = fragment

    parser = ParseTree.new()
    fallbacks = [:with_closing_end, :with_closing_brace]

    begin
      @fragment_sexp = parser.parse_tree_for_string(fragment)
      
    rescue SyntaxError=>ex
      # Try and find some way to make this parse
      if lenient && (fallback = fallbacks.shift)
        fragment = self.send(fallback, initial_fragment)
        retry
      else
        raise # re-raise exception, there's nothing we can do to make this valid.
      end
    end
    
    @fragment = fragment
  end
  
  # Matches any single element.
  def satisfy?(o, data={})
    capture_match o, data
  end

  def inspect
    "rb(#{sexp})"
  end
  
  private
  def with_closing_end(fragment)
    fragment + "; end"
  end
  
  def with_closing_brace(fragment)
    fragment + "; }"
  end
end