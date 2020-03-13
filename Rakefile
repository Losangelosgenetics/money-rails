require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task default: :spec

RSpec::Core::RakeTask.new

task :environment do
  require_relative 'lib/monetize'
end

desc 'Start a console with library loaded'
task console: :environment do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end
require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"

CLOBBER.include('doc', '.yardoc')

require "yard"

YARD::Rake::YardocTask.new do |t|
  t.options << "--files" << "CHANGELOG.md,LICENSE"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
end

task default: :spec
