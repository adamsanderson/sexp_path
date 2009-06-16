module SexpPath
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

  class SexpBlockMatch < SexpMatcher
    attr_reader :exp
    def initialize &block
      @exp = block
    end
  
    def satisfy?(o, data={})
      return nil unless @exp[o]
    
      capture_match o, data
    end
  
    def inspect
      "<custom>"
    end
  end

  class SexpAtom < SexpMatcher
    def satisfy?(o, data={})
      return nil if o.is_a? Sexp
    
      capture_match o, data
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
    end

    def inspect
      "t(#{sexp_type.inspect})"
    end
  end

  class SexpWildCard < SexpMatcher
    def satisfy?(o, data={})
      capture_match o, data
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
    end
  
    def inspect
      "include(#{value.inspect})"
    end
  end
end