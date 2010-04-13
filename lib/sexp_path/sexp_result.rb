module SexpPath
  
  # Wraps the results of a SexpPath query.  The matching Sexp
  # is placed in SexpResult#sexp.  Any named captures will be
  # available with SexpResult#[].
  #
  # For instance:
  #   res = s(:a) / Q?{ s( _ % 'name') }
  #
  #   res.first.sexp == s(:a) 
  #   res.first['name'] == :a
  #
  class SexpResult < Hash
    attr_accessor :sexp # Matched Sexp
    
    def initialize(sexp, data={})
      @sexp = sexp
      merge! data
    end

    # Shortcut for querying directly against a result's
    # Sexp.
    def search(pattern, data={})
      @sexp.search(pattern,data)
    end
    alias_method :/, :search
    
    def to_s
      if empty?
        @sexp.to_s
      else
        matches = self.map{|k,v| "#{k}:#{v}"}.join(", ")
        "#{@sexp} [#{matches}]"
      end
    end
    
    def inspect
      "#{@sexp} #{super}"
    end
  end
end
