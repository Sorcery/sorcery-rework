# frozen_string_literal: true

Sorcery.configure do |config|
  config.user_class = 'User'
  config.session_class = 'UserSession'

  config.password_hashing_algorithm = :bcrypt

  config.load_plugin(:brute_force_protection)
  config.load_plugin(:remember_me)
end
