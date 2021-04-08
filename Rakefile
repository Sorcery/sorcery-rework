# frozen_string_literal: true

# TODO: Make it so the gem tasks works for the meta gem and all plugin gems/core
# require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: [:rubocop, :spec]
