# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    email { Faker::Internet.email }
  end
end
