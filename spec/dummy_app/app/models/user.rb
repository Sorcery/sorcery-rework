# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.username_attribute_names = [:username]

    config.unload_plugin(:brute_force_protection)
    # config.load_plugin(:brute_force_protection,
    #   {
    #     model:
    #     {
    #       lock_expires_at_attribute_name: :pineapple_at
    #     }
    #   }
    # )
  end

  validates :username, presence: true
end
