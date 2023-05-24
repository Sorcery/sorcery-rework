# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoreController do
  let(:username) { Faker::Internet.username }
  let(:password) { Faker::Internet.password }
  let!(:user) { create(:user, username: username, password: password) }

  describe 'login' do
    context 'when given valid credentials' do
      before do
        post :create, params: { login: username, password: password }
      end

      it 'writes user session id in session' do
        # FIXME: Why is this a string and not an integer?
        expect(session[:user_session_id]).to eq user.user_sessions.first.id.to_s
      end

      it 'sets csrf token in session' do
        expect(session[:_csrf_token]).to be_present
      end
    end

    context 'when given invalid credentials' do
      before do
        post :create, params: { login: username, password: 'invalid' }
      end

      it 'sets user_session_id in session to nil' do
        expect(session[:user_session_id]).to be_nil
      end
    end
  end

  describe 'logout' do
    before do
      post :create, params: { login: username, password: password }
    end

    it 'clears the session' do
      expect(session[:user_session_id]).to be_present

      delete :destroy

      expect(session[:user_session_id]).to be_nil
    end
  end

  # FIXME: Bad practices go brrrr
  # rubocop:disable RSpec/InstanceVariable
  describe 'logged_in?' do
    subject { @controller.logged_in? }

    context 'when the user is logged in' do
      before do
        post :create, params: { login: username, password: password }
      end

      it { should be_truthy }
    end

    context 'when the user is not logged in' do
      it { should be_falsey }
    end
  end

  describe 'current_user' do
    subject { @controller.current_user }

    context 'when the user is logged in' do
      before do
        post :create, params: { login: username, password: password }
      end

      it { should eq user }
    end

    context 'when the user is not logged in' do
      it { should be_nil }
    end
  end

  describe 'login_as_user' do
    it 'logs in a user instance' do
      expect(@controller).not_to be_logged_in

      @controller.login_as_user(user)

      expect(@controller).to be_logged_in
    end

    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it 'works even if current_user is already nil' do
      post :create, params: { login: username, password: password }

      expect(@controller.current_user).to eq user

      delete :destroy

      expect(@controller.current_user).to be_nil

      post :login_with_login_as_user, params: { username: username }

      expect(@controller.current_user).to eq user
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe 'require_login' do
    context 'when using get' do
      before do
        get :restricted
      end

      it 'saves the originally requested URL' do
        expect(
          session[:return_to_url]
        ).to eq 'http://test.host/plugins/core/restricted'
      end

      it 'redirects to root' do
        expect(response).to redirect_to root_path
      end

      it 'redirects to the original URL on successful login' do
        post :create, params: { login: username, password: password }

        expect(response).to redirect_to 'http://test.host/plugins/core/restricted'
      end
    end

    [:post, :put, :delete].each do |http_method|
      context "when using #{http_method}" do
        before do
          send(http_method, :restricted)
        end

        it 'does not save the originally requested URL' do
          expect(session[:return_to_url]).to be_nil
        end

        it 'redirects to root' do
          expect(response).to redirect_to root_path
        end

        it 'redirects to root_path on successful login' do
          post :create, params: { login: username, password: password }

          expect(response).to redirect_to root_path
        end
      end
    end

    context 'when using JSON' do
      before do
        get :restricted, format: :json
      end

      it 'does not save the originally requested URL' do
        expect(session[:return_to_url]).to be_nil
      end

      it 'redirects to root' do
        expect(response).to redirect_to root_path
      end

      it 'redirects to root_path on successful login' do
        post :create, params: { login: username, password: password }

        expect(response).to redirect_to root_path
      end
    end

    context 'when using XHR' do
      before do
        get :restricted, xhr: true
      end

      it 'does not save the originally requested URL' do
        expect(session[:return_to_url]).to be_nil
      end

      it 'redirects to root' do
        expect(response).to redirect_to root_path
      end

      it 'redirects to root_path on successful login' do
        post :create, params: { login: username, password: password }

        expect(response).to redirect_to root_path
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
