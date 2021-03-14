# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.username_attribute_names = [:username]

    # config.unload_plugin(:brute_force_protection)
    config.load_plugin(
      :brute_force_protection,
      {
        model: {
          consecutive_login_retries_amount_limit: 3,
          failed_logins_count_attribute_name:     :pineapple_count,
          lock_expires_at_attribute_name:         :pineapple_at,
          unlock_token_attribute_name:            :pineapple_token
        }
      }
    )
  end

  validates :username, presence: true
end
