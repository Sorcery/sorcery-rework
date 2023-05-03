# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HttpBasicAuthController do
  let(:username) { Faker::Internet.username }
  let(:password) { Faker::Internet.password }
  let!(:user) { create(:user, username: username, password: password) }

  context 'when no credentials are sent' do
    before do
      get :restricted_with_http_basic_auth,
        params:  {},
        session: { http_authentication_used: true }
    end

    it 'responds with 401 unauthorized' do
      expect(response).to have_http_status(:unauthorized)
    end

    it 'denies access' do
      expect(response.body).to eq("HTTP Basic: Access denied.\n")
    end
  end

  # FIXME: It feels wrong that this redirects with a flash message. Is this the
  #        best way to handle bad credentials being passed via http basic auth?
  context 'when invalid credentials are sent' do
    before do
      send_http_basic_auth(username, 'invalid')
      get :restricted_with_http_basic_auth,
        params:  {},
        session: { http_authentication_used: true }
    end

    it 'responds with 302 found' do
      expect(response).to have_http_status(:found)
    end

    it 'redirects to the root' do
      expect(response).to redirect_to(root_path)
    end

    it 'denies access' do
      expect(flash[:alert]).to eq 'Please login first.'
    end
  end

  context 'when valid credentials are sent' do
    before do
      send_http_basic_auth(username, password)
      get :restricted_with_http_basic_auth,
        params:  {},
        session: { http_authentication_used: true }
    end

    it 'allows access' do
      expect(response).to be_successful
    end

    it 'sets the user session' do
      expect(UserSession.find(session[:user_session_id]).user).to eq user
    end
  end

  context 'when realm name is set' do
    around do |example|
      prev_val = described_class.sorcery_config.controller_to_realm_map
      described_class.sorcery_config.controller_to_realm_map =
        { 'http_basic_auth' => 'Salad' }
      example.run
      described_class.sorcery_config.controller_to_realm_map = prev_val
    end

    before do
      get :restricted_with_http_basic_auth,
        params:  {},
        session: { http_authentication_used: true }
    end

    it 'displays the correct realm name' do
      expect(response.headers['WWW-Authenticate']).to eq 'Basic realm="Salad"'
    end
  end
end
