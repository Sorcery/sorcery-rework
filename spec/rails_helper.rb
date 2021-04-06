# frozen_string_literal: true

require 'spec_helper'

################
## Load Rails ##
################
require 'rails/all'

##################
## Load Sorcery ##
##################
require 'sorcery-core'
require 'sorcery-jwt'
require 'sorcery-mfa'
require 'sorcery-oauth'

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

##########################
## Load RSpec Libraries ##
##########################
# NOTE: It's critical to include rspec/rails _after_ DummyApp! Otherwise we get
#       deprecation warnings from zeitwerk.
require 'rspec/rails'
require 'factory_bot_rails'
require 'shoulda-matchers'
require 'timecop'

###############################
## Load RSpec support folder ##
###############################

# Normally you would call Rails.root for this, but Rails.root refers to
# dummy_app rather than our actual root.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

#####################
## Configure RSpec ##
#####################
RSpec.configure do |config|
  config.mock_with :rspec

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  # Allow shortened FactoryBot syntax.
  # i.e. (create instead of FactoryBot.create)
  config.include FactoryBot::Syntax::Methods

  # Auto include model spec helper methods for all model specs
  config.include ModelSpecHelper, type: :model

  config.before(:suite) { MigrationHelper.setup_orm }
  config.after(:suite) { MigrationHelper.teardown_orm }
  config.before { ActionMailer::Base.deliveries.clear }
end

################################
## Configure Shoulda Matchers ##
################################
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
