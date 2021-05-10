# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.username_attr_names = [:username]

    config.load_plugin(:activity_logging)
    # config.unload_plugin(:brute_force_protection)
    config.load_plugin(
      :brute_force_protection,
      {
        model: {
          consecutive_login_retries_amount_limit: 3,
          failed_logins_count_attr_name:          :pineapple_count,
          lock_expires_at_attr_name:              :pineapple_at,
          unlock_token_attr_name:                 :pineapple_token
        }
      }
    )
  end

  has_many :user_sessions, dependent: :destroy

  validates :username, presence: true
end
