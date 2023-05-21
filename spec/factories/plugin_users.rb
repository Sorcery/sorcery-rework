# frozen_string_literal: true

FactoryBot.define do
  factory :plugin_user do
    username { Faker::Internet.username }
    email { Faker::Internet.email }
  end
end
