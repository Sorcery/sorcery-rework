# frozen_string_literal: true

require 'rails_helper'

oauth_providers = %w[
  auth0
  battlenet
  discord
  facebook
  github
  google
  instagram
  liveid
  line
  microsoft
  paypal
  salesforce
  slack
  vk
  wechat
]

RSpec.describe OAuthController do
  let(:username) { Faker::Internet.username }

  oauth_providers.each do |oauth_provider|
    context "when using #{oauth_provider} -" do
      describe 'redirect_at' do
        context 'when callback_url begins with "/"' do
          it 'redirects correctly'
          it 'logins with state'
          it 'logins with Graph API version'
          it 'logins without state after login with state'
        end

        context 'when callback_url begins with "https://"' do
          it 'redirects correctly'
        end
      end

      describe 'redirect_from' do
        context 'when user exists' do
          it 'allows login'
          it 'redirects back to original url'
        end

        context 'when user does not exist' do
          it 'denies login'
        end
      end

      describe 'create_from' do
        it 'creates a new user' do
          # expect(User).to receive(:create_from_provider).with(oauth_provider.to_s, '123', username: username)
          get :test_create_from_provider, params: { provider: oauth_provider }
        end

        it 'supports nested attributes'
        it 'does not crash on missing nested attributes'

        context 'when provided a block' do
          it 'does not create a user'
        end
      end

      context 'when using activity logging plugin' do
        it 'registers login time'
        it 'does not register login time if configured so'
      end

      context 'when using session_timeout plugin' do
        it 'does not reset session before session timeout'
        it 'resets session after session timeout'
      end

      context 'when using user_activation plugin' do
        it 'does not send activation email to external users'
        it 'does not send external users an activation success email'
      end
    end
  end
end
