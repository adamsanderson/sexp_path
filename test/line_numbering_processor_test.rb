require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sexp_path'
require 'parse_tree'

class LineNumberingProcessorTest < Test::Unit::TestCase  
  def setup
    @path = File.dirname(__FILE__) + '/sample.rb'
    #sample = File.read(path)
    #@sexp = Sexp.from_array(ParseTree.new.parse_tree_for_string(sample, path))
  end
  
  def test_processing_a_file_fills_in_all_the_line_numbers
    sexp = LineNumberingProcessor.process_file(@path)
    assert !sexp.empty?
    sexp.search_each(Q?{_}) do |s| 
      assert !sexp.line.nil?
      assert !sexp.file.nil?
    end
  end
end