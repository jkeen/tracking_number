require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

# if not defined?(Bundler)
#   require 'bundler'
#   begin
#     Bundler.setup(:default, :development)
#   rescue Bundler::BundlerError => e
#     $stderr.puts e.message
#     $stderr.puts "Run `bundle install` to install missing gems"
#     exit e.status_code
#   end
# end

require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  require 'tracking_number'

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tracking_number #{TrackingNumber::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
