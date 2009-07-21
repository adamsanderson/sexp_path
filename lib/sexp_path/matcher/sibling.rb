# See SexpPath::Matcher::Base for sibling relations: <,<<,>>,>
#
class SexpPath::Matcher::Sibling < SexpPath::Matcher::Base
  attr_reader :subject, :sibling, :distance
  
  # Creates a Matcher which will match any pair of Sexps that are siblings.
  # Defaults to matching the immediate following sibling.
  def initialize(subject, sibling, distance=nil)
    @subject = subject
    @sibling = sibling
    @distance = distance
  end
  
  # Satisfied if o contains +subject+ followed by +sibling+
  def satisfy?(o, data={})
    # Future optimizations: 
    # * Shortcut matching sibling
    subject_matches = index_matches(subject, o)
    return nil if subject_matches.empty?
    
    sibling_matches = index_matches(sibling, o)
    return nil if sibling_matches.empty?

    subject_matches.each do |i1, data_1|
      sibling_matches.each do |i2, data_2|
        if (distance ? (i2-i1 == distance) : i2 > i1)
          data = data.merge(data_1).merge(data_2)
          return capture_match(o, data)
        end
      end
    end
    
    nil
  end
  
  def inspect
    "#{subject.inspect} >> #{sibling.inspect}"
  end
  
  private  
  def index_matches(pattern, o)
    indexes = []
    return indexes unless o.is_a? Sexp
    
    o.each_with_index do |e,i|
      data = {}
      if pattern.is_a?(Sexp) ? pattern.satisfy?(o[i],data) : pattern == o[i]
        indexes << [i, data]
      end
    end
    
    indexes
  end
end