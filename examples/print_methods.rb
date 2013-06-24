require 'rubygems'
require File.dirname(__FILE__) + '/../lib/sexp_path'
require 'ruby_parser'

path = ARGV.shift
if !path
  puts "Prints classes and methods in a file"
  puts "usage:"
  puts "  ruby print_methods.rb <path>"
  exit
end

code = File.read(path)
sexp = RubyParser.new.parse(code, path)

# Use the ruby pattern matcher:
results = sexp / R?{ _class } / R?{ _method }

puts path
puts "-" * 80

results.each do |sexp_result|
  class_name = sexp_result['class']
  method_name = sexp_result['method']
  puts "#{class_name}##{method_name}"
end