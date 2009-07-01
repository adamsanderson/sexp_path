require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'
require 'parse_tree'

class LineNumberingProcessorTest < Test::Unit::TestCase  
  def setup
    @path = File.dirname(__FILE__) + '/sample.rb'
  end
  
  def test_processing_a_file_fills_in_all_the_line_numbers
    sexp = LineNumberingProcessor.rewrite_file(@path)
    assert !sexp.empty?
    sexp.search_each(Q?{_}) do |s| 
      assert !sexp.line.nil?, "Expected a line number for: #{s.sexp.inspect}"
      assert !sexp.file.nil?, "Expected a file for: #{s.sexp.inspect}"
    end
  end
  
  # This test may break if sample.rb changes
  def test_finding_known_lines
    sexp = LineNumberingProcessor.rewrite_file(@path)
    lines = open(@path,'r'){|io| io.readlines}
    
    assert_line_numbers_equal(
      lines, 'def test_b()', 
      sexp,  Q?{ s(:defn, :test_b, _) }
    )
    
    assert_line_numbers_equal(
      lines, '[apples, oranges, cakes]', 
      sexp,  Q?{ s(:array, s(:lvar, :apples), s(:lvar, :oranges), s(:lvar, :cakes)) }
    )
    
    assert_line_numbers_equal(
      lines, "require 'test/unit'",
      sexp, Q?{ s(:fcall, :require, s(:array, s(:str, "test/unit"))) }
    )
  end
  
  private
  def assert_line_numbers_equal(lines, code, sexp, pattern)
    string_line = find_line(lines, code)
    sexp_line =   (sexp / pattern).first.sexp.line
    
    assert_equal string_line, sexp_line, "Expected to find #{code} at line #{string_line}"
  end
  
  def find_line(lines, code)
    
    lines.each_with_index do |line,i|
      return i+1 if line.index(code) # 1 based indexing
    end
    return nil
  end
end