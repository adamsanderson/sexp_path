module SexpPath
  
  # The SexpQueryBuilder is the simplest way to build SexpPath queries.
  # 
  # Typically, one access the SexpQueryBuilder through the helper method
  # Q? which accepts a block, and will return a SexpPath matcher.
  #
  # For example here is a SexpPath query that looks for s(:a):
  #
  #   query = Q?{ s(:a) }
  # 
  # A more interesting query might look for classes with names starting
  # in Test:
  #
  #   query = Q?{ s(:class, m(/^Test\w+/ % 'name', _, _)) }
  #
  # This makes use of a SexpPath::Matcher::Pattern, two SexpPath::Matcher::Wild
  # matchers and SexpPath::Traverse#capture_as for capturing the name to a 
  # variable 'name'.
  #
  # For more examples, see the various SexpQueryBuilder class methods, the
  # examples, and the tests supplied with SexpPath.
  #
  class SexpQueryBuilder    
    class << self
      
      # This is the longhand method for create a SexpPath query, normally
      # one would use Q?{ ... }, however it is also possible to do:
      # 
      #   SexpPath::SexpQueryBuilder.do{ s() }
      #
      def do(&block)
        instance_eval(&block)
      end
      
      # Matches an S-Expression.
      #
      # example
      #   s(:a) / Q?{ s(:a) }       #=> [s(:a)]
      #   s(:a) / Q?{ s() }         #=> []
      #   s(:a, s(:b) / Q?{ s(:b) } #=> [s(:b)]
      #
      def s(*args)
        SexpPath::Matcher::Base.new(*args)
      end
      
      # Matches anything.
      #
      # example:
      #   s(:a) / Q?{ _ }        #=> [s(:a)]
      #   s(:a, s(s(:b))) / Q?{ s(_) } #=> [s(s(:b))]
      #
      # Can also be called with +wild+
      #   s(:a) / Q?{ wild }     #=> [s(:a)]
      #
      def wild()
        SexpPath::Matcher::Wild.new
      end
      alias_method :_, :wild
    
      def include(child)
        SexpPath::Matcher::Include.new(child)
      end
      
      # Matches any atom.
      #
      # example:
      #   s(:a) / Q?{ s(atom) }        #=> [s(:a)]
      #   s(:a, s(:b)) / Q?{ s(atom) } #=> [s(:b)]
      #
      def atom
        SexpPath::Matcher::Atom.new
      end
    
      # Matches when any sub expression match
      # 
      # example:
      #   s(:a) / Q?{ any(s(:a), s(:b)) } #=> [s(:a)]
      #   s(:a) / Q?{ any(s(:b), s(:c)) } #=> []
      #
      def any(*args)
        SexpPath::Matcher::Any.new(*args)
      end
      
      # Matches when all sub expression match
      #
      # example:
      #   s(:a) / Q?{ all(s(:a), s(:b)) } #=> []
      #   s(:a,:b) / Q?{ t(:a), include(:b)) } #=> [s(:a,:b)]
      #
      def all(*args)
        SexpPath::Matcher::All.new(*args)
      end
      
      # Matches when sub expression does not match, see SexpPath::Matcher::Base#-@
      #
      # example:
      #   s(:a) / Q?{ is_not(s(:b)) } #=> [s(:a)]
      #   s(:a) / Q?{ s(is_not :a) } #=> []
      #
      def is_not(arg)
        SexpPath::Matcher::Not.new(arg)
      end
      
      # Matches anything that has a child matching the sub expression
      # 
      # example:
      #   s(s(s(s(s(:a))))) / Q?{ child(s(:a)) } #=> [s(s(s(s(s(:a)))))]
      #
      def child(child)
        SexpPath::Matcher::Child.new(child)
      end
      
      # Matches anything having the same sexp_type, which is the first value in a Sexp.
      # 
      # example:
      #   s(:a, :b) / Q?{ t(:a) } #=> [s(:a, :b)]
      #   s(:a, :b) / Q?{ t(:b) } #=> []
      #   s(:a, s(:b, :c)) / Q?{ t(:b) } #=> [s(:b, :c)]
      def t(name)
        SexpPath::Matcher::Type.new(name)
      end
      
      # Matches any atom who's string representation matches the patterns passed in.
      # 
      # example:
      #   s(:a) / Q?{ m('a') } #=> [s(:a)]
      #   s(:a) / Q?{ m(/\w/,/\d/) } #=> [s(:a)]
      #   s(:tests, s(s(:test_a), s(:test_b))) / Q?{ m(/test_\w/) } #=> [s(:test_a), s(:test_b)]
      def m(* patterns)
        patterns = patterns.map{|p| p.is_a?(Regexp) ? p : Regexp.new("\\A"+Regexp.escape(p.to_s)+"\\Z")}
        regexp = Regexp.union(*patterns)
        SexpPath::Matcher::Pattern.new(regexp)
      end
    end
  end
end