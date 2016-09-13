# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'basicjrpc/version'

Gem::Specification.new do |spec|
  spec.name          = "basicjrpc"
  spec.version       = BasicJRPC::VERSION
  spec.authors       = ["Martin Simpson"]
  spec.email         = ["martin.c.simpson@gmail.com"]

  spec.summary       = "Basic JRPC Handler"
  spec.description   = "Basic JRPC Handler"
  spec.homepage      = "http://www.martin-simpson.net"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency 'nsq-ruby'
  spec.add_runtime_dependency 'redis'
  spec.add_runtime_dependency 'oj'  
  spec.add_runtime_dependency 'require_all'
end
