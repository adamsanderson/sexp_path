module SexpPath
  class SexpQueryBuilder    
    class << self
      def do(&block)
        instance_eval(&block)
      end
  
      def s(*args)
        SexpPath::Matcher::Base.new(*args)
      end
  
      def wild()
        SexpPath::Matcher::Wild.new
      end
      alias_method :_, :wild
    
      def include(child)
        SexpPath::Matcher::Include.new(child)
      end
  
      def atom(*args)
        SexpPath::Matcher::Atom.new
      end
    
      def any(*args)
        SexpPath::Matcher::Any.new(*args)
      end
    
      def all(*args)
        SexpPath::Matcher::All.new(*args)
      end
    
      def child(child)
        SexpPath::Matcher::Child.new(child)
      end
    
      def t(name)
        SexpPath::Matcher::Type.new(name)
      end
    
      def m(* patterns)
        patterns = patterns.map{|p| p.is_a?(Regexp) ? p : Regexp.new("\\A"+Regexp.escape(p.to_s)+"\\Z")}
        regexp = Regexp.union(*patterns)
        SexpPath::Matcher::Pattern.new(regexp)
      end
    end
  end
end