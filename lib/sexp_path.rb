require 'rubygems'
require 'sexp_processor'
require 'enumerator'
require 'pp'

module Traverse
  def search(pattern, data={})
    collection = SexpCollection.new
    search_each(pattern,data){|match| collection << match}
    collection
  end
  alias_method :/, :search
  
  def search_each(pattern, data={}, &block)
    return false unless pattern.is_a? Sexp
    
    if pattern.satisfy?(self, data)
      block.call(SexpMatch.new(self, data))
    end
    
    self.each do |subset|
      case subset
        when Sexp then subset.search_each(pattern, &block)
      end
    end
  end
end

class SexpMatch
  attr_accessor :sexp, :data
  def initialize(sexp, data)
    @sexp = sexp
    @data = data
  end
  
  def [] key
    data[key]
  end
end

class SexpCollection < Array
  def search(pattern)
    inject(SexpCollection.new){|collection, match| collection.concat match.sexp.search(pattern, match.data) }
  end
  alias_method :/, :search
end

class SexpMatcher < Sexp
  def | o
    SexpAnyMatcher.new(self, o)
  end
  
  def & o
    SexpAllMatcher.new(self, o)
  end
    
  def inspect
    children = map{|e| e.inspect}.join(', ')
    "q(#{children})"
  end
end

class SexpAnyMatcher < SexpMatcher
  attr_reader :options
  def initialize(*options)
    @options = options
  end
  
  def satisfy?(o, data={})
    return nil unless options.any?{|exp| exp.is_a?(Sexp) ? exp.satisfy?(o, data) : exp == o}
    
    capture_match o, data
    data
  end
  
  def inspect
    options.map{|o| o.inspect}.join(' | ')
  end
end

class SexpAllMatcher < SexpMatcher
  attr_reader :options
  def initialize(*options)
    @options = options
  end
  
  def satisfy?(o, data={})
    return nil unless options.all?{|exp| exp.is_a?(Sexp) ? exp.satisfy?(o, data) : exp == o}
    
    capture_match o, data
    data
  end
  
  def inspect
    options.map{|o| o.inspect}.join(' & ')
  end
end

class SexpChildMatcher < SexpMatcher
  attr_reader :child
  def initialize(child)
    @child = child
  end
  
  def satisfy?(o, data={})
    return nil unless child.satisfy?(o,data) || (o.respond_to?(:search_each) && o.search_each(child){ return true })
    
    capture_match o, data
    data
  end
  
  def inspect
    "_(#{child.inspect})"
  end
end

class SexpBlockMatch < SexpMatcher
  attr_reader :exp
  def initialize &block
    @exp = block
  end
  
  def satisfy?(o, data={})
    return nil unless @exp[o]
    
    capture_match o, data
    data
  end
  
  def inspect
    "<custom>"
  end
end

class SexpAtom < SexpMatcher
  def satisfy?(o, data={})
    return nil if o.is_a? Sexp
    
    capture_match o, data
    data
  end

  def inspect
    "atom"
  end
end

class SexpPatternMatcher < SexpMatcher
  attr_reader :pattern
  def initialize(pattern)
    @pattern = pattern
  end
  
  def satisfy?(o, data={})
    return nil unless !o.is_a?(Sexp) && o.to_s =~ pattern

    capture_match o, data
    data
  end

  def inspect
    "m(#{pattern.inspect})"
  end
end

class SexpTypeMatcher < SexpMatcher
  attr_reader :sexp_type
  def initialize(type)
    @sexp_type = type
  end
  
  def satisfy?(o, data={})
    return nil unless o.is_a?(Sexp) && o.sexp_type == sexp_type
    
    capture_match o, data
    data
  end

  def inspect
    "t(#{sexp_type.inspect})"
  end
end

class SexpWildCard < SexpMatcher
  def satisfy?(o, data={})
    capture_match o, data
    data
  end
  
  def inspect
    "wild"
  end
end

class SexpInclude < SexpMatcher
  attr_reader :value
  
  def initialize(value)
    @value = value
  end
  
  def satisfy?(o, data={})
    if o.is_a? Sexp
      return nil unless o.any?{|c| value.is_a?(Sexp) ? value.satisfy?(c, data) : value == c}
    end
    
    capture_match o, data
    data
  end
  
  def inspect
    "include(#{value.inspect})"
  end
end

class SexpQuery
  WILD = SexpWildCard.new()
  
  class << self
    def do(&block)
      instance_eval(&block)
    end
  
    def s(*args)
      SexpMatcher.new(*args)
    end
  
    def wild()
      WILD
    end
    alias_method :_, :wild
    
    def include(child)
      SexpInclude.new(child)
    end
  
    def atom(*args)
      SexpAtom.new
    end
    
    def any(*args)
      SexpAnyMatcher.new(*args)
    end
    
    def all(*args)
      SexpAllMatcher.new(*args)
    end
    
    def child(child)
      SexpChildMatcher.new(child)
    end
    
    def t(name)
      SexpTypeMatcher.new(name)
    end
    
    def m(* patterns)
      patterns = patterns.map{|p| p.is_a?(Regexp) ? p : Regexp.new("\\A"+Regexp.escape(p.to_s)+"\\Z")}
      regexp = Regexp.union(*patterns)
      SexpPatternMatcher.new(regexp)
    end
  end
end

def Q?(&block)
  SexpQuery.do(&block)
end

class Sexp
  include Traverse
  
  # Slight modification of Sexp equality so that we will consider anything that is
  # an Sexp, or a descendant of a sexp.
  def ==(obj)
    if obj.is_a?(Sexp) then
      super
    else
      false
    end
  end
  
  
  def satisfy?(o, data={})
    return false unless o.is_a? Sexp
    return false unless length == o.length
    each_with_index{|c,i| return false unless c.is_a?(Sexp) ? c.satisfy?( o[i], data ) : c == o[i] }

    capture_match(o, data)
    data
  end
  
  def capture_as(name)
    @capture_name = name
    self
  end
  alias_method :%, :capture_as
  
  private  
  def capture_match(matching_object, data)
    if @capture_name
      data[@capture_name] = matching_object
    end
  end
end