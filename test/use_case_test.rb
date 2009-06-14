require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'
require 'parse_tree'
require 'set'

# Here's a crazy idea, these tests actually use sexp_path on some "real"
# code to see if it can satisfy my requirements.
#
# These tests are two fold:
# 1. Make sure it works
# 2. Make sure it's not painful to use
class UseCaseTest < Test::Unit::TestCase  
  def setup
    path = File.dirname(__FILE__) + '/sample.rb'
    sample = File.read(path)
    @sexp = Sexp.from_array(ParseTree.new.parse_tree_for_string(sample, path))
  end
  
  def test_finding_methods
    methods = @sexp / Q?{ t(:defn) }
    assert_equal 5, methods.length
  end
  
  def test_finding_classes_and_methods
    res = @sexp / Q?{ s(:class, atom % 'name', _, _) }
    assert_equal 1, res.length
    assert_equal :ExampleTest, res.first['name']
    
    methods = res / Q?{ t(:defn) }
    assert_equal 5, methods.length
  end
  
  def test_finding_empty_test_methods
    empty_body = Q?{ s(:scope, s(:block, t(:args), s(:nil))) }
    res = @sexp / Q?{ s(:defn, m(/^test_.+/) % 'name', empty_body ) }
    assert_equal 1, res.length
    assert_equal :test_b, res.first['name']
  end
  
  def test_finding_duplicate_test_names
    res = @sexp / Q?{ s(:defn, m(/^test_.+/) % 'name', _ ) }
    seen = Set.new()
    repeated = 0
    res.each do |m|
      name = m['name']
      repeated += 1 if seen.include? name
      seen << name
    end
    
    assert_equal 1, repeated, "Should have caught test_a being repeated"
  end
  
  def test_rewriting_colon2s_oh_man_i_hate_those_in_most_cases_but_i_understand_why_they_are_there
    colon2 = Q?{ s(:colon2, s(:const, atom % 'const'), atom % 'scope') }
    
    # Hacky, could be done better
    while (results = (@sexp / colon2)) && !results.empty?
      results.each do |result|
        result.sexp.replace(s(:const, result.values_at('const','scope').join('::') ))
      end
    end
    
    expected_sexp = s(:const, "Test::Unit::TestCase")
    assert_equal 1, (@sexp / expected_sexp).length, @sexp.inspect
  end
end

# Contents of sample.rb sexp below:
__END__
s(:block,
 s(:call, nil, :require, s(:arglist, s(:str, "test/unit"))),
 s(:call, nil, :require, s(:arglist, s(:str, "test/unit/testcase"))),
 s(:class,
  :ExampleTest,
  s(:colon2, s(:colon2, s(:const, :Test), :Unit), :TestCase),
  s(:scope,
   s(:block,
    s(:defn,
     :setup,
     s(:args),
     s(:scope, s(:block, s(:call, s(:lit, 1), :+, s(:arglist, s(:lit, 2)))))),
    s(:defn,
     :test_a,
     s(:args),
     s(:scope,
      s(:block,
       s(:call,
        nil,
        :assert_equal,
        s(:arglist,
         s(:call, s(:lit, 1), :+, s(:arglist, s(:lit, 2))),
         s(:lit, 4)))))),
    s(:defn, :test_b, s(:args), s(:scope, s(:block, s(:nil)))),
    s(:defn,
     :test_a,
     s(:args),
     s(:scope,
      s(:block,
       s(:call,
        nil,
        :assert_equal,
        s(:arglist,
         s(:call, s(:lit, 1), :+, s(:arglist, s(:lit, 2))),
         s(:lit, 3)))))),
    s(:call, nil, :private, s(:arglist)),
    s(:defn,
     :helper_method,
     s(:args,
      :apples,
      :oranges,
      :cakes,
      s(:block, s(:lasgn, :cakes, s(:nil)))),
     s(:scope,
      s(:block,
       s(:iter,
        s(:call,
         s(:call,
          s(:array, s(:lvar, :apples), s(:lvar, :oranges), s(:lvar, :cakes)),
          :compact,
          s(:arglist)),
         :map,
         s(:arglist)),
        s(:lasgn, :food),
        s(:call,
         s(:call, s(:lvar, :food), :to_s, s(:arglist)),
         :upcase,
         s(:arglist))))))))))