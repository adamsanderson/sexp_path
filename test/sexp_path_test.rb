require 'test/unit'

require 'sexp_path'

class SexpPathTest < Test::Unit::TestCase
  include SexpMatchSpecials
  
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
    a = SexpAtom.new
    assert a == :a,  "Should match a symbol"
    assert a == 1,   "Should match a number"
    assert a == nil, "Should match nil"
    assert a != [],  "Should not match an array"
    assert a != s(), "Should not match an sexp"
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
    w = SexpWildCard.new
    assert w == :a,  "Should match a symbol"
    assert w == 1,   "Should match a number"
    assert w == nil, "Should match nil"
    assert w == [],  "Should match an array"
    assert w == s(), "Should match an sexp"
  end
  
  def test_searching_with_wildcard
    assert_search_count s(:add, :a, :b), Q?{s(:add, wild, :b)} , 1, 
      "wild should match :a"
      
    assert_search_count @ast_sexp, Q?{s(:defn, wild, s(wild, :a, :b) )}, 2, 
      "wilds should match :foo/:bar and :add/:sub"
      
    assert_search_count s(:a, s()), Q?{s(:a, wild)}, 1, 
      "wild should match s()"
      
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
    assert Q?{s(:a) | s(:b)}  == s(:a), "q(:a) should match s(:a)"
    assert Q?{s(:a) | s(:b)}  != s(:c), "Should not match s(:c)"
    
    assert_search_count s(:a, s(:b, :c), s(:b, :d)), Q?{s(:b, :c) | s(:b, :d)}, 2, 
      "Should match both (:b, :c) and (:b, :d)"
      
    assert_search_count @ast_sexp, Q?{s(:add, :a, :b) | s(:defn, :bar, WILD)}, 2, 
      "Should match at any level" 
  end
  
  # For symetry, kind of silly examples
  def test_and_matcher
    assert Q?{s(:a) & s(:b)}    != s(:a), "s(:a) is not both s(:a) and s(:b)"
    assert Q?{s(:a) & s(atom)}  == s(:a), "s(:a) matches both criteria"
  end
  
  def test_child_matcher    
    assert_search_count @ast_sexp, Q?{s(:class, :cake, _( s(:add, :a, :b) ) )}, 1,
      "Should match s(:class, :cake ...) and descend to find s(:add, :a, :b)"
        
    assert_search_count @ast_sexp, Q?{s(:class, :cake, _(include(:a)))}, 2,
      "Should match both the :a arguments"
  end
  
  def test_pattern_matcher
    assert Q?{m(/a/)}     == :a,        "Should match :a"
    assert Q?{m(/^test/)} == :test_case,"Should match :test_case"
    assert Q?{m('test')}  == :test,     "Should match :test #{Q?{m('test')}.inspect}"
    assert Q?{m('test')}  != :test_case,"Should only match whole word 'test'"
    assert Q?{m(/a/)}     != s(:a),     "Should not match s(:a)"
    
    assert_search_count @ast_sexp, Q?{s(m(/\w{3}/), :a, :b)}, 2,
      "Should match s(:add, :a, :b) and s(:sub, :a, :b)"
  end
  
  # Still not sure if I like this
  def test_block_matching
    sb = SexpBlockMatch
    
    assert sb.new{|o| o == s(:a)}     == s(:a), "Should match simple equality"
    assert sb.new{|o| o.length == 1}  == s(:a), "Should match length check"
    
    assert_search_count s(:a, s(:b), s(:c), s(:d,:t) ), sb.new{|o| o.length == 2 }, 1, 
      "Should match s(:d, :t)"
  end
  
  private
  def assert_search_count(sexp, example, count, message)
    i = 0
    sexp.search(example){|m| i += 1}
    assert_equal count, i, message + "\nSearching for: #{example.inspect}\nIn: #{sexp.inspect}"
  end
end