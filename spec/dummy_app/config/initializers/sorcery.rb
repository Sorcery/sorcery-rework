# frozen_string_literal: true

Sorcery.configure do |config|
  config.user_class = 'User'

  config.load_plugin(:brute_force_protection)
end
