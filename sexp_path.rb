require 'rubygems'
require 'sexp_processor'
require 'enumerator'
require 'pp'

module Traverse
  def search(pattern)
    Enumerable::Enumerator.new(self, :search_each, pattern).inject(SexpCollection.new){|m,e| m << e; m}
  end
  alias_method :/, :search
  
  def search_each(pattern, &block)
    if pattern == self
      block.call(self) 
    end
    
    self.each do |subset|
      case subset
        when Sexp then subset.search_each(pattern, &block)
      end
    end
  end
end

class SexpCollection < Array
  def search(pattern)
    inject(SexpCollection.new){|collection, sexp| collection.concat sexp.search(pattern) }
  end
  alias_method :/, :search
end

class SexpMatcher < Sexp
  def ===(o)
    self == o
  end
  
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
  
  def == o
    options.any?{|exp| exp == o}
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
  
  def == o
    options.all?{|exp| exp == o}
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
  
  def == o
    o == child || (o.respond_to?(:search_each) && o.search_each(child){ return true })
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
  
  def ==(o)
    !!@exp[o]
  end
  
  def inspect
    "<custom>"
  end
end

class SexpAtom < SexpMatcher
  def ==(o)
    !o.is_a? Sexp
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
  
  def ==(o)
    !o.is_a?(Sexp) && o.to_s =~ pattern
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
  
  def ==(o)
    o.is_a?(Sexp) && o.sexp_type == sexp_type
  end

  def inspect
    "t(#{sexp_type.inspect})"
  end
end

class SexpWildCard < SexpMatcher
  def ==(o)
    return true
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
  
  def ==(o)
    if o.respond_to? :include?
      return o.include?(value)
    else
      o == value
    end
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

module SexpMatchSpecials
  ATOM = SexpAtom.new
  WILD = SexpWildCard.new
  def INCLUDE(sexp); return SexpInclude.new(sexp); end
end

class Sexp
  include Traverse
  
  def ==(obj) # :nodoc:
    if obj.is_a?(Sexp) then
      super
    else
      false
    end
  end
end