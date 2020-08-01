# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    # byebug
  end

  validates :username, presence: true
end
