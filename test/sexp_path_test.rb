require 'test/unit'

require 'sexp_path'

class Test_SomethingToTest < Test::Unit::TestCase
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
    assert_search_count s(:add, :a, :b), Q?{s(:add, ATOM, :b)} , 1, 
      "atom should match :a"
      
    assert_search_count @ast_sexp, Q?{s(:defn, ATOM, s(ATOM, :a, :b) )}, 2, 
      "atoms should match :foo/:bar and :add/:sub"
      
    assert_search_count s(:a, s()), Q?{s(:a, ATOM)}, 0, 
      "atom should not match s()"
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
    
    assert_search_count @ast_sexp, Q?{s(:defn, atom, include(:a))}, 2, 
      "Sexp should match :defn with an sexp including :a"
    
    assert_search_count s(:a, s(:b, s(:c))), Q?{s(:a, include(:c))}, 0, 
      "Include should not descend"
  end
  
  def test_sexp_matcher_or_syntax
    assert Q?{s(:a) | s(:b)}  == s(:a), "q(:a) should match s(:a)"
    
    assert_search_count s(:a, s(:b, :c), s(:b, :d)), Q?{s(:b, :c) | s(:b, :d)}, 2, 
      "Should match both (:b, :c) and (:b, :d)"
      
    assert_search_count @ast_sexp, Q?{s(:add, :a, :b) | s(:defn, :bar, WILD)}, 2, 
      "Should match at any level" 
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