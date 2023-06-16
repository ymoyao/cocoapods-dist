# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-dist/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-dist'
  spec.version       = CocoapodsDist::VERSION
  spec.authors       = ['youhui']
  spec.email         = ['developer_yh@163.com']
  spec.description   = %q{a cocoapods plugin to display particular component outdated information In a xcode project.}
  spec.summary       = %q{--tag: show tags only; --commit: show all addtion commits.}
  spec.homepage      = 'https://github.com/ymoyao/cocoapods-dist'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
