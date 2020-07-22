# frozen_string_literal: true

# TODO: Dry up adding libs to load path.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-core', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-mfa', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../sorcery-oauth', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['RAILS_ENV'] ||= 'test'

# TODO: Rails is currently unnecessary, and breaks due to missing a database
#       connection.

# require 'rails/all'
# require 'rspec/rails'
require 'byebug'
