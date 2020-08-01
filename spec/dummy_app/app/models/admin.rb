# frozen_string_literal: true

class Admin < ApplicationRecord
  authenticates_with_sorcery! do |config|
    # byebug
  end

  validates :email, presence: true
end
