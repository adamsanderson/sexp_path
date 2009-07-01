require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'

class RubyFragmentTest < Test::Unit::TestCase
  def test_parsing_strict_ruby_strings
    assert_parses_ruby_strictly '1',            "Should handle simple literals"
    assert_parses_ruby_strictly '1+2',          "Should handle simple expressions"
    assert_parses_ruby_strictly '[1,a,3,:a]',   "Should handle arrays, and various types"
    assert_parses_ruby_strictly 'def cake; 1; end', "Should handle method definitions"
    assert_parses_ruby_strictly '1 + ((INTEGER))', "Should allow placeholder values"
  end
  
  def test_parsing_valid_ruby_fragments
    assert_parses_ruby_leniently 'def cake',                        "Should handle opened methods"
    assert_parses_ruby_leniently 'class Cake',                      "Should handle opened classes"
    assert_parses_ruby_leniently "class Cake\n attr_reader :attr",  "Should handle partial classes"
    assert_parses_ruby_leniently '[1,2,3].each do |a|',             "Should handle do/end blocks"
    assert_parses_ruby_leniently '[1,2,3].each{|a|',                "Should handle {} blocks"
  end
  
  def test_placeholder_regexp
    regexp = SexpPath::Matcher::RubyFragment::PLACEHOLDER_REGEXP
    assert "1 + ((INTEGER))".match(regexp)
    assert "1 + ((A_VALUE))".match(regexp)
    assert "def ((__SECRET__));".match(regexp)
    
    assert !"1 + (( INTEGER ))".match(regexp)
    assert !"1 + ((ONE2THREE))".match(regexp)
    assert !"1 + ((ONE-TWO))".match(regexp)
    assert !"1 + (())".match(regexp)
  end
    
  def test_capturing_groups
    assert_captures '1+2', '1 + ((INTEGER))', 'integer' => s(:lit, 2)
    assert_captures 'a ? 2 : 3', '((COND)) ? ((TRUE)) : ((FALSE))',
      'cond' => s(:vcall, :a), 
      'true' => s(:lit, 2),
      'false'=> s(:lit, 3)
      
    assert_captures '[1,2].map{|a| a}', '[1,2].map{|a|', 'implicit' => s(:dvar, :a)
  end
  
  private
  def assert_parses_ruby_strictly(code, message=nil)
    assert_nothing_raised message do 
      matcher = SexpPath::Matcher::RubyFragment.new(code, false)
      assert_equal code, matcher.fragment, message
      assert matcher.fragment_sexp, message
    end
  end
  
  def assert_parses_ruby_leniently(code, message=nil)
    assert_nothing_raised message do 
      matcher = SexpPath::Matcher::RubyFragment.new(code, true)
      assert matcher.fragment.include?(code), message # Should contain fragment
    end
  end
  
  def assert_captures(source, pattern, expected)
    matcher = SexpPath::Matcher::RubyFragment.new(pattern, true)
    sexp = Sexp.from_array(ParseTree.new.parse_tree_for_string(source))
    actual = {}
    assert matcher.satisfy?(sexp, actual)
    assert_equal expected, actual
  end
end