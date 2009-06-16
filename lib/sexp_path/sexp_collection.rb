module SexpPath
  class SexpCollection < Array
    def search(pattern)
      inject(SexpCollection.new){|collection, match| collection.concat match.sexp.search(pattern, match) }
    end
    alias_method :/, :search
  end
end