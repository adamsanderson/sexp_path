require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |s|
    s.name = "sexp_path"
    s.summary = "Pattern matching for S-Expressions (sexp)."
    s.description = <<-DESC
      Allows you to do example based pattern matching and queries against S Expressions (sexp).
    DESC
    s.email = "netghost@gmail.com"
    s.homepage = "http://github.com/adamsanderson/sexp_path"
    s.authors = ["Adam Sanderson"]
    s.files = FileList["[A-Z]*", "{bin,lib,test,examples}/**/*"]
    
    s.add_dependency 'sexp_processor', '~> 3.0'
    
    # Testing
    s.test_files = FileList["test/**/*_test.rb"]
    s.add_development_dependency 'ParseTree', '~> 2.1'
  end

rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::RDocTask.new do |t|
  t.main = "README.rdoc"
  t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test