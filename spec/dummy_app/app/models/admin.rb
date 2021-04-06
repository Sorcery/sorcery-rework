# frozen_string_literal: true

class Admin < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.user_class = 'Admin'
  end

  validates :email, presence: true
end
