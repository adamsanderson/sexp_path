module SexpPath
  class RubyQueryBuilder < SexpQueryBuilder
    class << self
      def _method(name=nil, bind='method')
        s(:defn, v(name, bind), _, _)
      end
      
      def _class_method(name=nil, bind='class_method')
        s(:defs, v(name, bind), _, _)
      end
      
      def _call(name=nil, bind='call')
        s(:call, _, v(name, bind), _)
      end
      
      def _class(name=nil, bind='class')
        s(:class, v(name, bind), _, _)
      end
      
      def _variable(name=nil, bind='variable')
        tag = variable_tag(name, :ivar, :lvar)
        s(tag, v(name, var))
      end
      
      def _assignment(name=nil, bind='assignment')
        term = v(name, bind)
        tag = variable_tag(name, :iasgn, :lasgn)

        s(tag, term)     | # declaration 
        s(tag, term, _)  | # assignment
        (                  # block arument
          t(:args) & 
          ( # note this last case is wrong for regexps
            SexpPath::Matcher::Block.new{|s| s[1..-1].any?{|a| a == name}} % bind
          )
        )
      end
      
      private
      # Inserts the appropriate type of value given name.
      # For instance:
      #   v('/cake/') #=> /cake/ # regular expression match
      #   v('apple')  #=> :apple # atom match
      def v(name, bind)
        if name.nil?
          atom % bind
        else
          m(name) % bind
        end
      end
      
      def variable_tag(name, ivar, lvar)
        if name.nil?
          atom
        else
          name = name.is_a?(Regexp) ? name.inspect[1..-2] : name.to_s
          name[0..0] == '@' ? ivar : lvar
        end
      end
    end
  end
end