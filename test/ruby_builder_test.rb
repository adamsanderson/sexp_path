require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'
require 'parse_tree'

class RubyBuilderTest < Test::Unit::TestCase
  def setup
    path = File.dirname(__FILE__) + '/sample.rb'
    sample = File.read(path)
    @sexp = Sexp.from_array(ParseTree.new.parse_tree_for_string(sample, path))
  end
  
  def test_finding_a_class
    assert_search_count @sexp, RB?{ cls },                  1, "Should match the class ExampleTest"
    assert_search_count @sexp, RB?{ cls(:ExampleTest) },    1, "Should match the class ExampleTest"
    assert_search_count @sexp, RB?{ cls(atom) },            1, "Should match the ExampleTest's name"
    assert_search_count @sexp, RB?{ cls(:OtherTes) },       0, "Should not match"
    assert_search_count s(),   RB?{ cls },                  0, "Should not match empty Sexp"
  end
  
  private
  def assert_search_count(sexp, example, count, message)
    i = 0
    sexp.search_each(example){|match| i += 1}
    assert_equal count, i, message + "\nSearching for: #{example.inspect}\nIn: #{sexp.inspect}"
  end
end