module SexpPath
  class SexpResult < Hash
    attr_accessor :sexp
    def initialize(sexp, data={})
      @sexp = sexp
      merge! data
    end
  end
end