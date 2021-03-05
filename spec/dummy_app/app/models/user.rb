# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.username_attribute_names = [:username]
  end

  validates :username, presence: true
end
