# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "net/dnd/version"

Gem::Specification.new do |s|
  s.name        = "net-dnd"
  s.version     = Net::DND::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian V. Hughes"]
  s.email       = ["brianvh@dartmouth.edu"]
  s.homepage    = %(https://github.com/brianvh/net-dnd/)
  s.summary     = %(#{s.name}-#{s.version})
  s.description = %(Ruby library for DND lookups.)

  s.required_rubygems_version = ">= 1.3.7"
  s.rubyforge_project = "net-dnd"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', '~> 1.0.10'
  s.add_development_dependency 'rspec', '~> 2.5.0'
end
