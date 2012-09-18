$:.push File.expand_path("../lib", __FILE__)
require "flail/version"

Gem::Specification.new do |s|
  s.name        = "flail"
  s.version     = Flail::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John 'asceth' Long"]
  s.email       = ["machinist@asceth.com"]
  s.homepage    = "https://github.com/asceth/flail"
  s.summary     = "Rails exception handler"
  s.description = "Handle Rails exceptions with the fail flail."

  s.rubyforge_project = "flail"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'json'

  s.add_development_dependency 'actionpack', '~> 2.3.8'
  s.add_development_dependency 'activerecord', '~> 2.3.8'
  s.add_development_dependency 'activesupport', '~> 2.3.8'
  s.add_development_dependency 'fakeweb', '~> 1.3.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'sham_rack', '~> 1.3.0'
end
