require 'rubygems'
require File.dirname(__FILE__) + '/../lib/sexp_path'
require 'parse_tree'

path = ARGV.shift
if !path
  puts "Prints classes and methods in a file"
  puts "usage:"
  puts "  ruby print_methods.rb <path>"
  exit
end

code = File.read(path)
sexp = Sexp.from_array(ParseTree.new.parse_tree_for_string(code, path))

class_query = Q?{ s(:class, atom % 'class_name', _, _) }
method_query = Q?{ s(:defn, atom % 'method_name', _ ) }

results = sexp / class_query / method_query

puts path
puts "-" * 80

results.each do |sexp_result|
  class_name = sexp_result['class_name']
  method_name = sexp_result['method_name']
  puts "#{class_name}##{method_name}"
end