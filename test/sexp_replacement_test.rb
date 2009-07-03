require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'

class SexpReplacementTest < Test::Unit::TestCase  
  def test_replacing_exact_matches
    sexp = s(:a, s(:b), :c)
    actual = sexp.replace_sexp(s(:b)){ :b }
    
    assert_equal( s(:a, :b, :c), actual)
  end
  
  def test_replacing_root
    sexp = s(:a, s(:b), :c)
    actual = sexp.replace_sexp(Q?{t(:a)}){ s(:new) }
    
    assert_equal( s(:new), actual)
  end
  
  
end