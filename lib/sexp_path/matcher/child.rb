# See SexpQueryBuilder.child
class SexpPath::Matcher::Child < SexpPath::Matcher::Base
  attr_reader :child
  
  # Create a Child matcher which will match anything having a descendant matching +child+.
  def initialize(child)
    @child = child
  end
  
  # Satisfied if matches +child+ or +o+ has a descendant matching +child+.
  def satisfy?(o, data={})
    if child.satisfy?(o,data)
      capture_match o, data
    elsif o.is_a? Sexp
      o.search_each(child,data) do 
        return capture_match(o, data)
      end
    end
  end

  def inspect
    "child(#{child.inspect})"
  end
end