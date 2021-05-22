# frozen_string_literal: true

require File.expand_path('boot', __dir__)

module DummyApp
  class Application < Rails::Application
    config.load_defaults '6.0'

    config.eager_load = false
    config.action_controller.allow_forgery_protection = false
  end
end
