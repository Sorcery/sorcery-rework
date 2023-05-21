# frozen_string_literal: true

class PluginUser < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.username_attr_names = [:username]

    config.load_plugin(:activity_logging)
    config.load_plugin(:brute_force_protection)
    config.load_plugin(
      :user_activation,
      model: {
        user_activation_mailer: SorceryMailer
      }
    )
  end

  has_many :plugin_user_sessions, dependent: :destroy

  validates :username, :email, presence: true
end
