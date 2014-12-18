# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tracking_number/version"

Gem::Specification.new do |s|
  s.name = %q{tracking_number}
  s.version = TrackingNumber::VERSION
  s.platform = Gem::Platform::RUBY

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Keen"]
  s.date = %q{2011-04-26}
  s.description = %q{Match tracking numbers to a service, and search blocks of text and pull out valid tracking numbers.}
  s.email = %q{jeff@keen.me}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.homepage = %q{http://github.com/jkeen/tracking_number}
  s.licenses = ["MIT"]
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Identifies valid tracking numbers}

  s.add_development_dependency('rake')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('activemodel')
  s.add_development_dependency('minitest')
end

