require 'test/unit'
require 'test/unit/testcase'

class ExampleTest < Test::Unit::TestCase  
  def setup
    1 + 2
  end
  
  def test_a
    assert_equal 1+2, 4
  end
  
  def test_b()
    # assert 1+1
  end
  
  def test_a
    assert_equal 1+2, 3
  end
  
  private 
  def helper_method apples, oranges, cakes=nil
    [apples, oranges, cakes].compact.map{|food| food.to_s.upcase}
  end
end