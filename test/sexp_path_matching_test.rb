require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'

class SexpMatchingPathTest < Test::Unit::TestCase  
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
  
  def test_searching_simple_examples
    assert_search_count @ast_sexp, :class, 0, 
      "Literal should match nothing"
    
    assert_search_count @ast_sexp, Q?{s(:class)}, 0, 
      "Should not exactly match anything"
      
    assert_search_count @ast_sexp, Q?{s(:add, :a, :b)}, 1, 
      "Should exactly match once"
      
    assert_search_count s(:a, s(:b, s(:c))), Q?{s(:b, s(:c))}, 1, 
      "Should match an exact subset"
    
    assert_search_count s(:a, s(:b, s(:c))), Q?{s(:a, s(:c))}, 0, 
      "Should not match the child s(:c)"
      
    assert_search_count @ast_sexp, Q?{s(:defn, :bar, s(:sub, :a, :b))}, 1, 
      "Nested sexp should exactly match once"
  end
  
  def test_equality_of_atom
    a = SexpPath::Matcher::Atom.new
    assert a.satisfy?(:a),  "Should match a symbol"
    assert a.satisfy?(1),   "Should match a number"
    assert a.satisfy?(nil), "Should match nil"
    assert !a.satisfy?(s()), "Should not match an sexp"
  end
  
  def test_searching_with_atom    
    assert_search_count s(:add, :a, :b), Q?{s(:add, atom, :b)} , 1, 
      "atom should match :a"
      
    assert_search_count @ast_sexp, Q?{s(:defn, atom, s(atom, :a, :b) )}, 2, 
      "atoms should match :foo/:bar and :add/:sub"
      
    assert_search_count s(:a, s()), Q?{s(:a, atom)}, 0, 
      "atom should not match s()"
  end
  
  def test_searching_with_any
    assert_search_count s(:foo, s(:a), s(:b)), Q?{s(any(:a,:b))}, 2, 
      "should not match either :a or :b"
      
    assert_search_count s(:foo, s(:a), s(:b)), Q?{any( s(:a) ,s(:c))}, 1, 
      "sexp should not match s(:a)"
  end
  
  def test_equality_of_wildacard
    w = SexpPath::Matcher::Wild.new
    assert w.satisfy?(:a  ),  "Should match a symbol"
    assert w.satisfy?(1   ),   "Should match a number"
    assert w.satisfy?(nil ), "Should match nil"
    assert w.satisfy?([]  ),  "Should match an array"
    assert w.satisfy?(s() ), "Should match an sexp"
  end
  
  def test_searching_with_wildcard
    assert_search_count s(:add, :a, :b), Q?{s(:add, wild, :b)} , 1, 
      "wild should match :a"
    
    assert_search_count @ast_sexp, Q?{s(:defn, :bar, _)}, 1,
      "should match s(:defn, :bar, s(..))"
      
    assert_search_count @ast_sexp, Q?{s(:defn, _, s(_, :a, :b) )}, 2, 
      "wilds should match :foo/:bar and :add/:sub"
      
    assert_search_count s(:a, s()), Q?{s(:a, _)}, 1, 
      "wild should match s()"
    
    assert_search_count s(:a, :b, :c), Q?{s(_,_,_)}, 1, 
      "multiple wilds should work"
    
    assert_search_count @ast_sexp, Q?{wild}, 6, 
      "wild should match every sub expression"
  end
  
  def test_searching_with_include
    assert_search_count s(:add, :a, :b), Q?{include(:a)} , 1, 
      "Sexp should include atom :a"
      
    assert_search_count @ast_sexp, Q?{include(:bar)}, 1, 
      "Sexp should include atom :bar"
      
    assert_search_count @ast_sexp, Q?{s(:defn, atom, include(:a))}, 2, 
      "Sexp should match :defn with an sexp including :a"
    
    assert_search_count @ast_sexp, Q?{include(:a)}, 2, 
      "Sexp should match an sexp including :a"
    
    assert_search_count s(:a, s(:b, s(:c))), Q?{s(:a, include(:c))}, 0, 
      "Include should not descend"
  end
  
  def test_or_matcher
    assert  Q?{s(:a) | s(:b)}.satisfy?( s(:a) ), "q(:a) should match s(:a)"
    assert !Q?{s(:a) | s(:b)}.satisfy?( s(:c) ), "Should not match s(:c)"
    
    assert_search_count s(:a, s(:b, :c), s(:b, :d)), Q?{s(:b, :c) | s(:b, :d)}, 2, 
      "Should match both (:b, :c) and (:b, :d)"
      
    assert_search_count @ast_sexp, Q?{s(:add, :a, :b) | s(:defn, :bar, _)}, 2, 
      "Should match at any level" 
  end
  
  # For symetry, kind of silly examples
  def test_and_matcher
    assert !Q?{s(:a) & s(:b)}.satisfy?(s(:a)), "s(:a) is not both s(:a) and s(:b)"
    assert  Q?{s(:a) & s(atom)}.satisfy?(s(:a)), "s(:a) matches both criteria"
  end
  
  def test_child_matcher    
    assert_search_count @ast_sexp, Q?{s(:class, :cake, child( s(:add, :a, :b) ) )}, 1,
      "Should match s(:class, :cake ...) and descend to find s(:add, :a, :b)"
        
    assert_search_count @ast_sexp, Q?{s(:class, :cake, child(include(:a)))}, 1,
      "Should match once since there exists a child which includes :a"
  end
  
  def test_not_matcher
    assert !Q?{-wild}.satisfy?(s(:a)),        "wild should match s(:a)"
    assert  Q?{-(s(:b))}.satisfy?(s(:a)),     "s(:b) should not match s(:b)"
    assert  Q?{is_not(s(:b))}.satisfy?(s(:a)),"should behave the same as unary minus"
    assert !Q?{-(s(atom))}.satisfy?(s(:a)),   "should not match, :a is an atom"
    assert  Q?{s(is_not(:b))}.satisfy?(s(:a)), "should match s(:a) since the atom is not :b"
  end
  
  def test_sibling_matcher
    assert_equal SexpPath::Matcher::Sibling, Q?{(s(:a) >> s(:b))}.class 
    
    assert  Q?{s(:a) >> s(:b)}.satisfy?( s(s(:a), s(:b)) ),        "should match s(:a) has an immediate sibling s(:b)"
    assert  Q?{s(:a) >> s(:b)}.satisfy?( s(s(:a), s(:b), s(:c)) ), "should match s(:a) has an immediate sibling s(:b)"
    assert  Q?{s(:a) >> s(:c)}.satisfy?( s(s(:a), s(:b), s(:c)) ), "should match s(:a) a sibling s(:b)"
    assert !Q?{s(:c) >> s(:a)}.satisfy?( s(s(:a), s(:b), s(:c)) ), "should not match s(:a) does not follow s(:c)"
    assert !Q?{s(:a) >> s(:a)}.satisfy?( s(s(:a)) ),               "should not match s(:a) has no siblings"
    assert  Q?{s(:a) >> s(:a)}.satisfy?( s(s(:a), s(:b), s(:a)) ), "should match s(:a) has another sibling s(:a)"
    
    assert_search_count @ast_sexp, Q?{t(:defn) >> t(:defn)}, 1,
      "Should match s(:add, :a, :b) followed by s(:sub, :a, :b)"
  end
  
  def test_pattern_matcher
    assert  Q?{m(/a/)}.satisfy?(:a),             "Should match :a"
    assert  Q?{m(/^test/)}.satisfy?(:test_case), "Should match :test_case"
    assert  Q?{m('test')}.satisfy?(:test),       "Should match :test #{Q?{m('test')}.inspect}"
    assert !Q?{m('test')}.satisfy?(:test_case), "Should only match whole word 'test'"
    assert !Q?{m(/a/)}.satisfy?(s(:a)),         "Should not match s(:a)"
    
    assert_search_count @ast_sexp, Q?{s(m(/\w{3}/), :a, :b)}, 2,
      "Should match s(:add, :a, :b) and s(:sub, :a, :b)"
  end
  
  def test_search_method
    assert_equal 1, @ast_sexp.search( s(:sub, :a, :b)).length
    assert_equal 2, @ast_sexp.search( Q?{s(:defn, atom, wild)} ).length
  end
  
  def test_search_collection
    # test method
    assert_equal SexpPath::SexpCollection, @ast_sexp.search( s(:sub, :a, :b)).class
    # test binary operator
    assert_equal SexpPath::SexpCollection, (@ast_sexp / s(:sub, :a, :b)).class
    # test sub searches
    collection = @ast_sexp / Q?{s(:defn, atom, _)} / Q?{s(atom, :a, :b)}
    assert_equal SexpPath::SexpCollection, collection.class
    assert_equal 2, collection.length
    assert_equal [s(:add, :a, :b), s(:sub, :a, :b)], collection.map{|m| m.sexp}
  end
  
  def test_sexp_type_matching
    assert Q?{t(:a)}.satisfy?( s(:a) )
    assert Q?{t(:a)}.satisfy?( s(:a, :b, s(:oh_hai), :d) )
    assert_search_count @ast_sexp, Q?{t(:defn)}, 2,
      "Should match s(:defn, _, _)"
  end
  
  # Still not sure if I like this
  def test_block_matching
    sb = SexpPath::Matcher::Block
    
    assert sb.new{|o| o == s(:a)}.satisfy?(s(:a)), "Should match simple equality"
    assert sb.new{|o| o.length == 1}.satisfy?(s(:a)), "Should match length check"
    
    assert_search_count s(:a, s(:b), s(:c), s(:d,:t) ), sb.new{|o| o.length == 2 }, 1, 
      "Should match s(:d, :t)"
  end
  
  private
  def assert_search_count(sexp, example, count, message)
    i = 0
    sexp.search_each(example){|match| i += 1}
    assert_equal count, i, message + "\nSearching for: #{example.inspect}\nIn: #{sexp.inspect}"
  end
end