require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'

class SexpPathCaptureTest < Test::Unit::TestCase  
  def setup
    @ast_sexp = # Imagine it looks like a ruby AST
      s(:class, :cake, 
        s(
          s(:defn, :foo, 
            s(:add, :a, :b)
          ),
          s(:defn, :bar, 
            s(:sub, :a, :b)
          )
        )
      )
  end
  
  def test_match_with_no_capture_defined_should_not_capture
    sexp = s(:a, :b, :c)
    assert_equal({}, Q?{ sexp }.satisfy?(sexp))
  end
  
  def test_match_with_capture_defined_should_capture
    sexp = s(:a, :b, :c)
    assert res = Q?{ sexp % 'cake' }.satisfy?(sexp)
    assert_equal(sexp, res['cake'])
  end
  
  def test_match_with_multiple_captures
    assert res = Q?{ s(:add, atom % 'A', atom % 'B') }.satisfy?( s(:add, :a, :b) )
    assert_equal(:a, res['A'])
    assert_equal(:b, res['B'])
  end
  
  def test_deep_matches
    assert res = Q?{ s(:class, atom % 'name', s( _ % 'def1', _ % 'def2')) }.satisfy?( @ast_sexp )
    assert_equal(:cake, res['name'])
    assert_equal(s(:defn, :foo, s(:add, :a, :b)), res['def1'])
    assert_equal(s(:defn, :bar, s(:sub, :a, :b)), res['def2'])
  end
  
  def test_simple_searching
    res = @ast_sexp / Q?{ s(:class, atom % 'name', _) }
    assert_equal 1, res.length
    assert_equal :cake, res.first['name']
  end
  
  def test_iterative_searching
    result = @ast_sexp / Q?{ s(:class, atom % 'class', _) } / Q?{ s(:defn, atom % 'method', _) }
    assert_equal 2, result.length, "Should have matched both defn nodes"
    
    result.each do |match_data|
      assert match_data['method'], "Should have captured to 'method'"
      assert match_data['class'], "Should have propogated 'class' capture"
    end
  end
  
  def test_capturing_any_matchers
    sexp = s(:add, :a, :b)
    assert res = Q?{ any(s(:add, :a, :b), s(:sub, :a, :b)) % 'match' }.satisfy?( sexp )
    assert_equal sexp, res['match']
    
    assert res = Q?{ any(s(atom % 'name', :a, :b), s(:sub, :a, :b)) % 'match' }.satisfy?( sexp )
    assert_equal sexp, res['match']
    assert_equal :add, res['name']
  end
  
  def test_capturing_all_matchers
    sexp = s(:add, :a, :b)
    assert res = Q?{ all(s(_, :a, :b), s(atom, :a, :b)) % 'match' }.satisfy?( sexp )
    assert_equal sexp, res['match']
    
    assert res = Q?{ all(s(_ % 'wild', :a, :b), s(atom % 'atom', :a, :b)) % 'match' }.satisfy?( sexp )
    assert_equal sexp, res['match']
    assert_equal :add, res['wild']
    assert_equal :add, res['atom']
  end
  
  def test_capturing_type_matches
    sexp = s(:add, :a, :b)
    assert res = Q?{ t(:add) % 'match' }.satisfy?( sexp )
    assert_equal sexp, res['match']
  end
  
  def test_capturing_child_matches
    sexp = s(:a, s(:b, s(:c)))
    assert res = Q?{ s(:a, child( s(atom % 'atom') ) % 'child' ) }.satisfy?( sexp )
    assert_equal s(:b, s(:c)), res['child']
    assert_equal :c, res['atom']
  end
  
  def test_catpuring_pattern_matches
    sexp = s(:add, :a, :b)
    assert res = Q?{ s(m(/a../) % 'regexp', :a, :b) }.satisfy?( sexp )
    assert_equal :add, res['regexp']
  end
  
  def test_catpuring_include_matches
    sexp = s(:add, :a, :b)
    assert res = Q?{ include(:a) % 'include' }.satisfy?( sexp )
    assert_equal sexp, res['include']
  end
  
  def test_catpuring_nested_include_matches
    sexp = s(:add, s(:a), :b)
    assert res = Q?{ include(s(atom % 'atom' )) % 'include' }.satisfy?( sexp )
    assert_equal sexp, res['include']
    assert_equal :a, res['atom']
  end
  
  def test_capturing_negations
    sexp = s(:b)
    assert res = Q?{ (-s(:a)) % 'not' }.satisfy?( sexp )
    assert_equal s(:b), res['not']
  end
  
  def test_capturing_negation_contents
    sexp = s(:a, :b)
    assert res = Q?{ -((include(:b) % 'b') & t(:c)) }.satisfy?( sexp )
    assert !res['b'], 'b should not be included'
  end
  
  def test_capturing_siblings
    sexp = s(s(:a), s(s(:b)), s(:c))
    assert res = Q?{ (s(atom) % 'a') >> (s(atom) % 'c') }.satisfy?( sexp )
    assert_equal s(:a), res['a']
    assert_equal s(:c), res['c']
  end
  
end