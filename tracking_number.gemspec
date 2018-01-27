# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tracking_number/version"

Gem::Specification.new do |s|
  s.name = %q{tracking_number}
  s.version = TrackingNumber::VERSION
  s.platform = Gem::Platform::RUBY

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Keen"]
  s.date = %q{2017-02-21}
  s.description = %q{This gem identifies valid tracking numbers and the service they're associated with. It can also tell you a little bit about the package purely from the number—there's quite a bit of info tucked away into those numbers, it turns out.}
  s.email = %q{jeff@keen.me}
  s.extra_rdoc_files = [
    "LICENSE.txt",
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.homepage = %q{http://github.com/jkeen/tracking_number}
  s.licenses = ["MIT"]
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Identifies valid tracking numbers}

  s.add_development_dependency('rake', '~> 10.4.2')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('activemodel', '~> 4.2.5.1')
  s.add_development_dependency('minitest','~> 5.5')
end
