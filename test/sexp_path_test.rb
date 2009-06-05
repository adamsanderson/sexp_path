require 'test/unit'

require 'sexp_path'

class Test_SomethingToTest < Test::Unit::TestCase
  include SexpMatchSpecials
  
  def setup
    @ast_sexp = # Imagine it looks like a ruby AST
      s(:class, :Cake, 
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
      
    assert_search_count @ast_sexp, s(:class), 0, 
      "Should not exactly match anything"
      
    assert_search_count @ast_sexp, s(:add, :a, :b), 1, 
      "Should exactly match once"
      
    assert_search_count @ast_sexp, s(:defn, :bar, s(:sub, :a, :b)), 1, 
      "Nested sexp should exactly match once"
  end
  
  def test_searching_with_atom    
    assert_search_count s(:add, :a, :b), s(:add, ATOM, :b) , 1, 
      "ATOM should match :a"
      
    assert_search_count @ast_sexp, s(:defn, ATOM, s(ATOM, :a, :b) ), 2, 
      "ATOMs should match :foo/:bar and :add/:sub"
      
    assert_search_count s(:a, s()), s(:a, ATOM), 0, 
      "ATOM should not match s()"
  end
  
  def test_searching_with_wildcard
    assert_search_count s(:add, :a, :b), s(:add, WILD, :b) , 1, 
      "WILD should match :a"
      
    assert_search_count @ast_sexp, s(:defn, WILD, s(WILD, :a, :b) ), 2, 
      "WILDs should match :foo/:bar and :add/:sub"
      
    assert_search_count s(:a, s()), s(:a, WILD), 1, 
      "WILD should match s()"
      
    assert_search_count @ast_sexp, WILD, 6, 
      "WILD should match every sub expression"
  end
  
  def test_searching_with_include
    assert_search_count s(:add, :a, :b), s(:add, WILD, :b) , 1, 
      "WILD should match :a"
      
    assert_search_count @ast_sexp, s(:defn, WILD, s(WILD, :a, :b) ), 2, 
      "WILDs should match :foo/:bar and :add/:sub"
      
    assert_search_count s(:a, s()), s(:a, WILD), 1, 
      "WILD should match s()"
      
    assert_search_count @ast_sexp, WILD, 6, 
      "WILD should match every sub expression"
  end
  
  private
  def assert_search_count(sexp, example, count, message)
    i = 0
    sexp.search(example){|m| i += 1}
    assert_equal count, i, message + "\nSearching for: #{example.inspect}\nIn: #{sexp.inspect}"
  end
end