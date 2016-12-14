# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'havenondemand/version'

Gem::Specification.new do |spec|
  spec.name          = "havenondemand"
  spec.version       = Havenondemand::VERSION
  spec.authors       = ["Phong Vu", "Tyler Nappy", " Martin Zerbib"]
  spec.email         = ["phong.vu@hpe.com"]
  spec.summary       = %q{Haven OnDemand Ruby Client}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/HP-Haven-OnDemand/havenondemand-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "unirest"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
