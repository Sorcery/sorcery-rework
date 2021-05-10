# frozen_string_literal: true

class UserSession < ApplicationRecord
  belongs_to :user
end
