module SexpPath
  class SexpQueryBuilder  
    class << self
      def do(&block)
        instance_eval(&block)
      end
  
      def s(*args)
        SexpMatcher.new(*args)
      end
  
      def wild()
        SexpWildCard.new
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
end