# frozen_string_literal: true

class Admin < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.user_class    = 'Admin'
    config.session_class = 'AdminSession'

    config.password_digest_attr_name  = :cryptic
    config.password_hashing_algorithm = :argon2

    config.load_plugin(
      :brute_force_protection,
      {
        model: { consecutive_login_retries_amount_limit: 3 }
      }
    )
  end

  has_one :admin_session, dependent: :destroy

  validates :email, presence: true
end
