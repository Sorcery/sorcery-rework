# frozen_string_literal: true

# TODO: Dry up adding libs to load path.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-core', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-mfa', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-oauth', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['RAILS_ENV'] ||= 'test'

require 'byebug'

# Run specs without checking code coverage with `coverage=false rspec`
unless ENV['coverage'] == 'false'
  require 'simplecov'

  SimpleCov.start do
    # Paths to be ignored
    add_filter '/spec/'

    # Groups to be tested
    add_group 'Core', 'sorcery-core/lib'
    add_group 'MFA', 'sorcery-mfa/lib'
    add_group 'OAuth', 'sorcery-oauth/lib'

    track_files '{sorcery-core, sorcery-mfa, sorcery-oauth}/lib/**/*.{rb}'

    # TODO: Uncomment and implement coverage as needed until met.
    # SimpleCov.minimum_coverage 95
    # SimpleCov.minimum_coverage_by_file 50
  end
end
