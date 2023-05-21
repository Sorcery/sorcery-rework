# frozen_string_literal: true

require File.expand_path('boot', __dir__)

module DummyApp
  class Application < Rails::Application
    config.load_defaults '6.1'

    config.eager_load = false
    config.action_controller.allow_forgery_protection = false
    config.action_mailer.delivery_method = :test
  end
end
