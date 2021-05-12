# frozen_string_literal: true

# TODO: Dry up adding libs to load path.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-core', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-jwt', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-mfa', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-oauth', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['RAILS_ENV'] ||= 'test'

require 'byebug'
require 'faker'

############################
## Generate Test Coverage ##
############################

# Run specs without checking code coverage with `coverage=false rspec`
unless ENV['coverage'] == 'false'
  require 'simplecov'

  SimpleCov.start do
    # Paths to be ignored
    add_filter '/spec/'

    # Groups to be tested
    add_group 'Core', 'sorcery-core/lib'
    add_group 'JWT', 'sorcery-jwt/lib'
    add_group 'MFA', 'sorcery-mfa/lib'
    add_group 'OAuth', 'sorcery-oauth/lib'

    track_files '{sorcery-core, sorcery-mfa, sorcery-oauth}/lib/**/*.{rb}'

    # TODO: Uncomment and implement coverage as needed until met.
    # SimpleCov.minimum_coverage 95
    # SimpleCov.minimum_coverage_by_file 50
  end
end

#####################
## Configure RSpec ##
#####################
RSpec.configure do |config|
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Find load order dependencies
  config.order = :random
  # Allow replicating load order dependency
  # by passing in same seed using --seed
  Kernel.srand config.seed

  # Allows you to pass the `--only-failures` flag to RSpec.
  config.example_status_persistence_file_path = 'tmp/rspec_example_status.txt'

  # Find slow specs by running `profiling=true rspec`
  config.profile_examples = 5 if ENV['profiling'] == 'true'
end
