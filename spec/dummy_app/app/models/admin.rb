# frozen_string_literal: true

class Admin < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.user_class = 'Admin'
    config.session_class = 'AdminSession'

    config.password_hashing_algorithm = :argon2
  end

  has_one :admin_session, dependent: :destroy

  validates :email, presence: true
end
