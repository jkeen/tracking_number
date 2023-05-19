# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tracking_number/version'

Gem::Specification.new do |s|
  s.name = 'tracking_number'
  s.version = TrackingNumber::VERSION
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Jeff Keen']
  s.description = "This gem identifies valid tracking numbers and the service they're associated with. It can also tell you a little bit about the package purely from the number—there's quite a bit of info tucked away into those numbers, it turns out."
  s.email = 'jeff@keen.me'
  s.extra_rdoc_files = [
    'LICENSE.txt'
  ]

  s.files = `git ls-files`.split("\n")

  gem_dir = "#{File.expand_path(File.join(__FILE__, '..'))}/"
  `git submodule --quiet foreach pwd`.split($OUTPUT_RECORD_SEPARATOR).each do |submodule_path|
    Dir.chdir(submodule_path.chomp) do
      submodule_relative_path = submodule_path.sub gem_dir, ''

      # issue git ls-files in submodule's directory
      submodule_files = `git ls-files -- couriers/*`.split($OUTPUT_RECORD_SEPARATOR)

      # prepend the submodule path to create absolute file paths
      submodule_files_fullpaths = submodule_files.map do |filename|
        "#{submodule_path}/#{filename}"
      end

      # remove leading path parts to get paths relative to the gem's root dir
      # (this assumes, that the gemspec resides in the gem's root dir)
      submodule_files_paths = submodule_files_fullpaths.map do |filename|
        filename.gsub gem_dir, ''
      end

      # add relative paths to gem.files
      s.files += submodule_files_paths
    end
  end

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/jkeen/tracking_number'
  s.licenses = ['MIT']
  s.summary = 'Identifies valid tracking numbers'

  s.add_runtime_dependency('activesupport', '>= 4.2.5')
  s.add_runtime_dependency('json', '>= 1.8.3')
  s.add_development_dependency('activemodel', '> 4.2.5.1')
  s.add_development_dependency('minitest', '~> 5.5')
  s.add_development_dependency('minitest-reporters', '~> 1.1')
  s.add_development_dependency('rake', '~> 13.0')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('terminal-table')
end
