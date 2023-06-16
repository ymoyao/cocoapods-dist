# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-dist/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-dist'
  spec.version       = CocoapodsDist::VERSION
  spec.authors       = ['youhui']
  spec.email         = ['developer_yh@163.com']
  spec.description   = %q{A short description of cocoapods-dist.}
  spec.summary       = %q{A longer description of cocoapods-dist.}
  spec.homepage      = 'https://github.com/EXAMPLE/cocoapods-dist'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
