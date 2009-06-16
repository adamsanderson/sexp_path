require 'rubygems'
require 'sexp_processor'

require 'sexp_path/traverse'
require 'sexp_path/matchers'
require 'sexp_path/sexp_query_builder'
require 'sexp_path/sexp_result'
require 'sexp_path/sexp_collection'

def Q?(&block)
  SexpPath::SexpQueryBuilder.do(&block)
end

class Sexp
  include SexpPath::Traverse
end