# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sexp_path}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Sanderson"]
  s.date = %q{2009-06-14}
  s.description = %q{      Allows you to do example based pattern matching and queries against S Expressions (sexp).
}
  s.email = %q{netghost@gmail.com}
  s.files = [
    "Rakefile",
    "VERSION.yml",
    "lib/sexp_path.rb",
    "test/sample.rb",
    "test/sexp_path_capture_test.rb",
    "test/sexp_path_matching_test.rb",
    "test/use_case_test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/adamsanderson/sexp_path}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Pattern matching for S Expressions (sexp).}
  s.test_files = [
    "test/sexp_path_capture_test.rb",
    "test/sexp_path_matching_test.rb",
    "test/use_case_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sexp_processor>, ["~> 3.0"])
      s.add_development_dependency(%q<ParseTree>, ["~> 2.1"])
    else
      s.add_dependency(%q<sexp_processor>, ["~> 3.0"])
      s.add_dependency(%q<ParseTree>, ["~> 2.1"])
    end
  else
    s.add_dependency(%q<sexp_processor>, ["~> 3.0"])
    s.add_dependency(%q<ParseTree>, ["~> 2.1"])
  end
end
