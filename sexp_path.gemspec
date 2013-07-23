Gem::Specification.new do |s|
  s.name             = "sexp_path"
  s.version          = "0.5.1"
  s.platform         = Gem::Platform::RUBY
  
  s.summary          = "Pattern matching for S-Expressions"
  s.description      = "Example based structural pattern matching for S-Expressions"
  
  s.license          = 'MIT'
  
  s.authors          = ["Adam Sanderson"]
  s.email            = "netghost@gmail.com"
  s.homepage         = 'https://github.com/adamsanderson/sexp_path'
  
  s.files            = Dir.glob('{bin,lib,examples,test}/**/*') + ["README.rdoc", "Gemfile"]
  s.require_path     = 'lib'
  
  s.extra_rdoc_files = ["README.rdoc"]
  s.rdoc_options.concat ['--main',  'README.rdoc']
  
  s.add_runtime_dependency      "sexp_processor", "~> 4.2"
  s.add_development_dependency  "ruby_parser",    "~> 3.2"
end