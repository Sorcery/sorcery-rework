# frozen_string_literal: true

require File.expand_path('boot', __dir__)

# In a real application, bundler would auto include this for us.
require 'sorcery-core'

# TODO: Uncomment or remove
# require 'sorcery-mfa'
# require 'sorcery-oauth'

module DummyApp
  class Application < Rails::Application
    config.load_defaults '6.0'

    config.eager_load = true
    config.autoloader = :zeitwerk
  end
end
