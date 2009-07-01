require 'parse_tree' rescue nil

# Transforms a Sexp, keeping track of newlines.  This uses the internal ruby newline nodes
# so they must be included in the Sexp to be transformed.  If ParseTree is being used, it should
# be configured to include newlines:
#
#   parser = ParseTree.new(true) # true => include_newlines
# 
# LineNumberingProcessor.rewrite_file(path) should be used as a short cut if ParseTree is available.
#
class LineNumberingProcessor < SexpProcessor
  # Helper method for generating a Sexp with line numbers from a file at +path+.
  #
  # Only available if ParseTree is loaded.
  def self.rewrite_file(path)
    raise 'ParseTree must be installed.' unless Object.const_defined? :ParseTree
    
    code = File.read(path)
    sexp = Sexp.from_array(ParseTree.new(true).parse_tree_for_string(code, path).first)
    processor = LineNumberingProcessor.new
    
    # Fill in the first lines with a value
    sexp.line = 0
    sexp.file = path
    
    # Rewrite the sexp so that everything gets a line number if possible.
    processor.rewrite sexp
  end
  
  # Creates a new LineNumberingProcessor.
  def initialize()
    super
    @unsupported.delete :newline
  end
  
  # Rewrites a Sexp using :newline nodes to fill in line and file information.
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
  
  private
  # Removes newlines from the expression, they are read inside of rewrite, and used to give
  # the other nodes a line number and file.
  def rewrite_newline(exp)
    # New lines look like:
    #  s(:newline, 21, "test/sample.rb", s(:call, nil, :private, s(:arglist)) )
    sexp = exp[3]
    rewrite(sexp)
  end
end