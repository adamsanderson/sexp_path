module SexpPath
  # == Experimental
  # This is a special interface for building queries against ruby AST S-Expressions.
  # It is likely to change, but it's also probably awesome.
  #
  # The RubyQueryBuilder is an extension of the standard SexpQueryBuilder, you can still
  # use the normal SexpQueryBuilder, but this allows you to do some more ruby specific stuff
  # including pattern matching against fragments of ruby code.
  class RubyQueryBuilder < SexpQueryBuilder
    class << self
      # Generates a matcher using a fragment of ruby code.
      # Requires ParseTree to be installed at the moment.
      #
      def rb(fragment)
        SexpPath::Matcher::RubyFragment.new(fragment)
      end
      
      # Matches a ruby Class node.
      #  s(:class,'name','parent','contents')
      #
      def cls(name= atom, parent= wild, contents= wild)
        s(:class, name_argument(name), parent, contents)
      end
      
      # Matches a ruby method definition node.
      #  s(:defn, 'name', 'args', 'contents')
      def defn(name= atom, args= wild, contents= wild)
        s(:defn, name_argument(name), args, contents)
      end
      
      private
      def name_argument(name)
        case name
          when String, Regexp then m(name)
          else name
        end
      end
      
    end
  end
end