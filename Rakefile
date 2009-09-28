require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "penctl-ruby"
    gemspec.summary = "Ruby implementation of penctl"
    gemspec.description = "With penctl-ruby you can add and remove servers to a pen server list and to change settings without the need to restart the pen balancer."
    gemspec.email = "jannis@gmail.com"
    gemspec.homepage = "http://github.com/jayniz/penctl-ruby"
    gemspec.authors = ["Jannis Hermanns"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Generate documentation for InheritedResources.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'InheritedResources'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Run all specs for penctl-ruby"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Default runs specs"
task :default => :spec