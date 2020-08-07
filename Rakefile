# frozen_string_literal: true

# FIXME: This breaks due to a root-level gemspec not being found
# require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: [:rubocop, :spec]
