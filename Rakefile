require 'rake'

organisation = "com.blinkbox.books.marvin"
name = "onix2-processor"
version = File.read("VERSION").strip

task :default => :test

desc "Runs all tests"
task :test do
  Rake::Task['spec'].invoke
  Rake::Task['features'].invoke
end

desc "Run all rspec tests"
begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end
rescue LoadError => e
  raise e
  task :spec do
    $stderr.puts "Please install rspec: `gem install rspec`"
  end
end

desc "Test all features"
begin
  require 'cucumber'
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    $stderr.puts "Please install cucumber: `gem install cucumber`"
  end
end

namespace :build do
  desc "Builds a docker container"
  task :docker do
    exec "docker build -t #{organisation.split(".").last}/#{name}:#{version} ."
  end
end