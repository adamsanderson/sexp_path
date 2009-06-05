require 'test/unit'
require 'test/unit/testcase'

class ExampleTest < Test::Unit::TestCase  
  def setup
    1 + 2
  end
  
  def test_a
    assert_equal 1+2, 4
  end
  
  def test_b
    # assert 1+1
  end
  
  def test_a
    assert_equal 1+2, 3
  end
    
end