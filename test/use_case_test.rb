require 'test/unit'
require 'sexp_path'
require 'parse_tree'
require 'set'

# Here's a crazy idea, these tests actually use sexp_path on some "real"
# code to see if it can satisfy my requirements.
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
    classes = @sexp / Q?{ t(:class) }
    assert_equal 1, classes.length
    example_test = classes.first
    assert_equal :ExampleTest, example_test[1]
    
    methods = example_test / Q?{ t(:defn) }
    assert_equal 5, methods.length
  end
  
  def test_finding_empty_test_methods
    empty_body = Q?{ s(:scope, s(:block, t(:args), s(:nil))) }
    methods = @sexp / Q?{ s(:defn, m(/^test_.+/), empty_body ) }
    assert_equal 1, methods.length
    assert_equal :test_b, methods.first[1]
  end
  
  def test_finding_duplicate_test_names
    methods = @sexp / Q?{ s(:defn, m(/^test_.+/), _ ) }
    seen = Set.new()
    repeated = 0
    methods.each do |m|
      name = m[1]
      repeated += 1 if seen.include? name
      seen << name
    end
    
    assert_equal 1, repeated, "Should have caught test_a being repeated"
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