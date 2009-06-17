module SexpPath
  # Wraps the results of a SexpPath query.
  # SexpCollection defines SexpCollection#search so that you can
  # chain queries.
  # 
  # For instance:
  #   res = s(:a, s(:b)) / Q?{ s(:a,_) } / Q?{ s(:b) }
  #
  class SexpCollection < Array
    # See Traverse#search
    def search(pattern)
      inject(SexpCollection.new){|collection, match| collection.concat match.sexp.search(pattern, match) }
    end
    alias_method :/, :search
  end
end