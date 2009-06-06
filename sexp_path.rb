require 'rubygems'
require 'sexp_processor'
require 'pp'

module Traverse
  def search(pattern, &block)
    if pattern == self
      block.call(self)
    end

    self.each do |subset|
      case subset
      when Sexp then
        subset.search(pattern, &block)
      end
    end
  end
  
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
    !o.is_a? Array
  end

  def inspect
    "atom"
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
    "INCLUDE(#{value.inspect})"
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
    
    def include(child)
      SexpInclude.new(child)
    end
  
    def atom(*args)
      if args.empty?
        SexpAtom.new
      else
        SexpAnyMatcher.new(*args)
      end
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