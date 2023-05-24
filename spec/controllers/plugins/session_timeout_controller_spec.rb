# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionTimeoutController do
  let(:username) { Faker::Internet.username }
  let(:password) { Faker::Internet.password }
  let!(:user) { create(:user, username: username, password: password) }

  after do
    Timecop.return
  end

  context 'when a user has an expired session' do
    before do
      post :create, params: { login: username, password: password }
      Timecop.travel(2.hours.from_now)
    end

    it 'resets the expired session' do
      expect(session[:user_session_id]).to be_present

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_nil
    end
  end

  context 'when a user has a valid session' do
    before do
      post :create, params: { login: username, password: password }
    end

    it 'does not reset the valid session' do
      expect(session[:user_session_id]).to be_present

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present
    end

    it 'works if the login time is stored as a String' do
      session[:login_time] = Time.current.to_s

      expect(session[:user_session_id]).to be_present

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present
    end

    it 'works if the login time is stored as a Time' do
      session[:login_time] = Time.current

      expect(session[:user_session_id]).to be_present

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present
    end
  end

  # TODO: Should there be a dedicated test file for integration tests of
  #       multiple plugins?
  context 'when a user logs in via remember_me cookie' do
    before do
      post :login_with_remember_me,
        params: { username: username, password: password }
      delete :purge_session
      reload_cookies
    end

    it 'registers login time' do
      expect(session[:login_time]).to be_nil

      get :show_if_logged_in

      expect(session[:login_time]).to be_present
    end
  end

  # rubocop:disable Layout/LineLength
  context 'when session_timeout_invalidate_active_sessions_enabled is true' do
    around do |example|
      prev_val = described_class.sorcery_config.session_timeout_invalidate_active_sessions_enabled
      described_class.sorcery_config.session_timeout_invalidate_active_sessions_enabled = true
      example.run
      described_class.sorcery_config.session_timeout_invalidate_active_sessions_enabled = prev_val
    end

    before do
      post :create, params: { login: username, password: password }
    end

    it 'does not reset the session if invalidate_sessions_before is nil' do
      user.update!(invalidate_sessions_before: nil)

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present
    end

    it 'does not reset the session if it was not created before invalidate_sessions_before' do
      user.update!(invalidate_sessions_before: 10.minutes.ago)

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present
    end

    it 'resets the session if the session was created before invalidate_sessions_before' do
      user.update!(invalidate_sessions_before: Time.current)

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_nil
    end

    it 'resets active sessions on next action if invalidate_active_sessions! is called' do
      get :invalidate_sessions

      expect(session[:user_session_id]).to be_present

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_nil
    end

    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it 'allows login after invalidate_active_sessions! is called' do
      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present

      # Call to invalidate
      get :invalidate_sessions

      # Check that existing sessions were logged out
      get :show_if_logged_in

      expect(session[:user_session_id]).to be_nil

      # Check that new session is allowed to login
      post :create, params: { login: username, password: password }

      expect(session[:user_session_id]).to be_present

      # Check an additional request to make sure not logged out on next request
      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'when session_timeout_from_last_action is true' do
    around do |example|
      prev_val = described_class.sorcery_config.session_timeout_from_last_action
      described_class.sorcery_config.session_timeout_from_last_action = true
      example.run
      described_class.sorcery_config.session_timeout_from_last_action = prev_val
    end

    before do
      post :create, params: { login: username, password: password }
    end

    # rubocop:disable RSpec/ExampleLength
    it 'does not logout if there was activity' do
      Timecop.travel(45.minutes.from_now)

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present

      Timecop.travel(45.minutes.from_now)

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present
    end
    # rubocop:enable RSpec/ExampleLength

    it 'with \'session_timeout_from_last_action\' logs out if there was no activity' do
      get :show_if_logged_in

      expect(session[:user_session_id]).to be_present

      Timecop.travel(90.minutes.from_now)

      get :show_if_logged_in

      expect(session[:user_session_id]).to be_nil
    end
  end
  # rubocop:enable Layout/LineLength
end
