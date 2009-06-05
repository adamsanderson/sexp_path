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

class SexpAtom < SexpMatchSpecial
  def ==(o)
    o and !o.is_a? Array
  end

  def ===(o)
    o and !o.is_a? Array
  end

  def inspect
    "ATOM"
  end
end

class SexpWildCard < SexpMatchSpecial
  def === (o)
    return true
  end
  
  def == (o)
    return true
  end
  
  def inspect
    "WILD"
  end
end

class SexpInclude < SexpMatchSpecial
  def initialize(value)
    @value = value
  end
  
  def === (o)
    if o.respond_to? :include?
      return o.include?(value)
    else
      o == value
    end
  end
  
  def == (o)
    if o.respond_to? :include?
      return o.include?(value)
    else
      o == value
    end
  end
end

module SexpMatchSpecials
  ATOM = SexpAtom.new
  WILD = SexpWildCard.new
  def INCLUDE(sexp); return SexpInclude.new(sexp); end
end

class Sexp
  include Traverse
end

if __FILE__ == $0
  include SexpMatchSpecials
  
  sexp = s(:class, :Cake, s(
      s(:defn, :foo, 
        s(:add, :a, :b)
      ),
      s(:defn, :bar, 
        s(:sub, :a, :b)
      )
    )
  )
  
  pp sexp
  puts "Search :defn"
  sexp.search(s(:defn)){|m| pp m}
  
  puts "Search :class"
  sexp.search(s(:class)){|m| pp m}
    
  puts "Search (:add, :a, :b)"
  sexp.search(s(:add, :a, :b)){|m| pp m}
  
  puts "Search (:add, ATOM(), :b)"
  sexp.search(s(:add, ATOM(), :b)){|m| pp m}
  
  puts "Search (:defn, :foo, ANY())"
  sexp.search(s(:defn, :foo, ANY())){|m| pp m}
  
  puts "Search INCLUDE(:a)"
  sexp.search(INCLUDE(:a)){|m| pp m}
  
  # puts "Search ANY"
  # sexp.search( ANY() ){|m| pp m}
  
  puts "Each of type :defn"
  sexp.each_of_type(:defn){|m| pp m}
  
  puts "Each of type ANY"
  sexp.each_of_type( ANY() ){|m| pp m}
  
end