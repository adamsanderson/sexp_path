require 'parse_tree' rescue nil

# Processes a Sexp, keeping track of newlines, 
class LineNumberingProcessor < SexpProcessor
  # Helper method for generating a Sexp with line numbers.
  #
  # Only available if ParseTree is loaded.
  def self.process_file(path)
    raise 'ParseTree must be installed.' unless Object.const_defined? :ParseTree
    
    code = File.read(path)
    sexp = Sexp.from_array(ParseTree.new(true).parse_tree_for_string(code, path).first)
    processor = LineNumberingProcessor.new
    sexp.line = 0
    sexp.file = path
    processor.rewrite sexp
  end
  
  def initialize()
    super
    self.auto_shift_type = true
    @unsupported.delete :newline
    @env = Environment.new
  end
  
  def rewrite exp
    unless exp.nil?
      if exp.sexp_type == :newline
        @line = exp[1]
        @file = exp[2]
      end
      
      exp.file ||= @file
      exp.line ||= @line
    end
    
    super exp
  end
  
  def rewrite_newline(exp)
    # New lines look like:
    #  s(:newline, 21, "test/sample.rb", s(:call, nil, :private, s(:arglist)) )
    sexp = exp[3]
    rewrite(sexp)
  end
end