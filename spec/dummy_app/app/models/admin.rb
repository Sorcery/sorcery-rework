# frozen_string_literal: true

class Admin < ApplicationRecord
  authenticates_with_sorcery!

  validates :email, presence: true
end
