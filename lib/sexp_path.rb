require 'rubygems'
require 'sexp_processor'

module SexpPath
  
  # SexpPath Matchers are used to build SexpPath queries.
  #
  # See also: SexpQueryBuilder
  module Matcher  
  end
end

# Query Support
require 'sexp_path/traverse'
require 'sexp_path/sexp_query_builder'
require 'sexp_path/sexp_result'
require 'sexp_path/sexp_collection'

# Matchers
require 'sexp_path/matcher/base'
require 'sexp_path/matcher/any'
require 'sexp_path/matcher/all'
require 'sexp_path/matcher/child'
require 'sexp_path/matcher/block'
require 'sexp_path/matcher/atom'
require 'sexp_path/matcher/pattern'
require 'sexp_path/matcher/type'
require 'sexp_path/matcher/wild'
require 'sexp_path/matcher/include'


# Pattern building helper, see SexpQueryBuilder
def Q?(&block)
  SexpPath::SexpQueryBuilder.do(&block)
end

# SexpPath extends Sexp with Traverse.
# This adds support for searching S-Expressions
class Sexp
  include SexpPath::Traverse
end