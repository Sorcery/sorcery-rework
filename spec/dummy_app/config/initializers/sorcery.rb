# frozen_string_literal: true

Sorcery.configure do |config|
  config.user_class = 'User'

  # FIXME: Enable this plugin again once base functionality is confirmed working
  # config.load_plugin(:brute_force_protection)
end
