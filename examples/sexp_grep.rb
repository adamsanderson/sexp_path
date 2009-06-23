require 'rubygems'
require File.dirname(__FILE__) + '/../lib/sexp_path'
require 'parse_tree'

# Example program, this will scan a file for anything
# matching the Sexp passed in.


pattern = ARGV.shift
paths = ARGV

if paths.empty? || !pattern
  puts "Prints classes and methods in a file"
  puts "usage:"
  puts "  ruby sexp_grep.rb <pattern> <path>"
  puts "example:"
  puts "  ruby sexp_grep.rb t(:defn) *.rb"
  exit
end

begin
  pattern = SexpPath::SexpQueryBuilder.instance_eval(pattern)
rescue Exception=>ex
  puts "Invalid Pattern: '#{pattern}'"
  puts "Trace:"
  puts ex
  puts ex.backtrace
  exit 1
end

paths.each do |path|
  code = File.read(path)
  sexp = Sexp.from_array(ParseTree.new.parse_tree_for_string(code, path))
  found = false
  
  sexp.search_each(pattern) do |match|
    if !found
      puts "\n** #{path} **"
      found = true
    end
    puts "\n#{match.sexp.inspect}"
  end
end