# frozen_string_literal: true

require 'spec_helper'

################
## Load Rails ##
################
require 'rails/all'
require 'rspec/rails'

############################
## Load Dummy Application ##
############################
# TODO: Clean up this explanation and correct any technical inaccuracies.
#
# This is necessary because we need to be able to test Sorcery in the context
# of an actual application. How it works is we load a Rails App called
# `DummyApp` by requiring the bootstrap file `environment.rb`. From there, any
# specs should be able to access Rails constants in the context of an
# Application that includes Sorcery.
#
require 'dummy_app/config/environment'

#####################
## Configure RSpec ##
#####################
RSpec.configure do |config|
  config.mock_with :rspec

  config.use_transactional_fixtures = false
end
