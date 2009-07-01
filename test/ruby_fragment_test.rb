require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'

class RubyFragmentTest < Test::Unit::TestCase
  def test_parsing_valid_ruby_strings
    assert_parses_ruby_strictly '1',            "Should handle simple literals"
    assert_parses_ruby_strictly '1+2',          "Should handle simple expressions"
    assert_parses_ruby_strictly '[1,a,3,:a]',   "Should handle arrays, and various types"
    
  end
  
  private
  def assert_parses_ruby_strictly(code, message=nil)
    assert_nothing_raised message do 
      matcher = SexpPath::Matcher::RubyFragment.new(code, true)
      assert_equal code, matcher.fragment, message
      assert matcher.fragment_sexp, message
    end
  end
end