# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BruteForceProtectionController do
  let(:username) { Faker::Internet.username }
  let(:password) { Faker::Internet.password }
  let!(:user) { create(:user, username: username, password: password) }

  # FIXME: Find a better way to directly test overriding the attribute field
  # names without causing normal tests like these to become more difficult to
  # read. (use specific models for that?)
  # rubocop:disable RSpec/ExampleLength
  it 'counts login retries' do
    expect(user.pineapple_count).to be_zero

    3.times do
      post :create, params: { login: username, password: 'invalid' }
    end

    user.reload
    expect(user.pineapple_count).to eq 3
  end

  it 'resets the counter on a good login' do
    2.times do
      post :create, params: { login: username, password: 'invalid' }
    end

    user.reload
    expect(user.pineapple_count).to eq 2

    post :create, params: { login: username, password: password }

    user.reload
    expect(user.pineapple_count).to be_zero
  end
  # rubocop:enable RSpec/ExampleLength
end
