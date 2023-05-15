# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RememberMeController do
  let(:username) { Faker::Internet.username }
  let(:password) { Faker::Internet.password }
  let!(:user) { create(:user, username: username, password: password) }

  context 'when remember_me! is called' do
    before do
      post :login_with_remember_me,
        params: { username: username, password: password }
    end

    it 'manually sets the remember_me cookie' do
      user.reload

      expect(cookies.signed['remember_me_token']).to be_present
      expect(cookies.signed['remember_me_token']).to eq user.reload.remember_me_token
    end

    it 'clears cookie on forget_me!' do
      expect(cookies.signed['remember_me_token']).to be_present

      get :page_with_forget_me

      expect(cookies.signed['remember_me_token']).to be_nil
    end

    it 'clears cookie on force_forget_me!' do
      expect(cookies.signed['remember_me_token']).to be_present

      get :page_with_force_forget_me

      expect(cookies.signed['remember_me_token']).to be_nil
    end

    it 'clears cookie on logout' do
      expect(cookies.signed['remember_me_token']).to be_present

      delete :destroy
      reload_cookies

      expect(cookies.signed['remember_me_token']).to be_nil
    end
  end

  context 'when remember_me! is not called' do
    before do
      post :login_without_remember_me,
        params: { username: username, password: password }
    end

    it 'does not manually set the remember_me cookie' do
      expect(cookies.signed['remember_me_token']).to be_nil
    end
  end

  context 'when user has remember_me cookie but is not logged in' do
    before do
      post :login_with_remember_me,
        params: { username: username, password: password }
      delete :purge_session
      reload_cookies
    end

    it 'logs the user in from their remember_me cookie' do
      get :show_if_logged_in

      expect(controller).to(
        set_flash[:success].to('You are logged in!')
      )
    end
  end

  context 'when logging in with remember_me set to true' do
    before do
      post :login_with_remember_me_parameter,
        params: { username: username, password: password, remember: '1' }
    end

    it 'sets the remember_me cookie' do
      expect(cookies.signed['remember_me_token']).to be_present
      expect(cookies.signed['remember_me_token']).to eq user.reload.remember_me_token
    end
  end

  context 'when logging in with remember_me set to false' do
    before do
      post :login_with_remember_me_parameter,
        params: { username: username, password: password, remember: '0' }
    end

    it 'does not set the remember_me cookie' do
      expect(cookies.signed['remember_me_token']).to be_nil
    end
  end

  context 'when not asked to remember_me' do
    before do
      post :login_with_remember_me_parameter,
        params: { username: username, password: password }
    end

    it 'does not set the remember_me cookie' do
      expect(cookies.signed['remember_me_token']).to be_nil
    end
  end

  context 'when using login_as_user' do
    before do
      post :login_with_login_as_user, params: { username: username }
    end

    it 'does not set the remember_me cookie' do
      expect(response).to be_successful
      expect(cookies.signed['remember_me_token']).to be_nil
    end
  end
end
