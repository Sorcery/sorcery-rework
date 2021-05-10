# frozen_string_literal: true

class AdminSession < ApplicationRecord
  belongs_to :admin

  validates :admin_id, uniqueness: true
end
