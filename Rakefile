require 'rake'
require 'rake/testtask'
require 'rdoc/task'

Rake::RDocTask.new do |t|
  t.main = "README.rdoc"
  t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc "Build a new version of SexpPath" 
task :build do
  `gem build sexp_path.gemspec`
end

desc "Removes build artifacts" 
task :clean do
  rm Dir["sexp_path*.gem"]
end

task :default => :test