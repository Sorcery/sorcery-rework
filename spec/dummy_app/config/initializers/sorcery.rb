# frozen_string_literal: true

Rails.application.config.sorcery.configure do |config|
  config.plugins = [:core, :mfa]
end
