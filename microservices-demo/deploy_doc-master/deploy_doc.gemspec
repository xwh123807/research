# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deploy_doc/version'

Gem::Specification.new do |spec|
  spec.name          = "deploy_doc"
  spec.version       = DeployDoc::VERSION
  spec.authors       = ["Maarten Hoogendoorn"]
  spec.email         = ["maarten@moretea.nl"]

  spec.summary       = %q{Test system for your deploment documentation for your application}
  spec.description   = %q{Using DeployDoc's, you can make your documentation executable}
  spec.homepage      = "https://github.com/microservices-demo/deploy_doc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
