# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'regenwolke_autons/version'

Gem::Specification.new do |spec|
  spec.name          = "regenwolke_autons"
  spec.version       = RegenwolkeAutons::VERSION
  spec.authors       = ["Dragan Milic"]
  spec.email         = ["dragan@netice9.com"]
  spec.summary       = %q{Regenwolke PAAS Autons}
  spec.description   = %q{Regenwolke PAAS Autons}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nestene", "~> 0.1.4"
  spec.add_dependency "structure_mapper", "~> 0.0.2"
  spec.add_dependency "docker-api", '~> 1.17.0'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"

end
