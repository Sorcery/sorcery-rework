# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiSessionsController do
  let(:user) { create :user, password: 'secret' }

  describe 'create' do
    context 'when logged in' do
      before do
        # FIXME: Should be able to set directly to login_as_user value?
        request.headers['Authorization'] =
          "Bearer #{controller.login_as_user(user)}"
        post :create,
          params:  { login: user.username, password: 'secret' }
      end

      it 'prevents logging in twice' do
        expect(request).to have_http_status :bad_request
        expect(request.body).to(
          eq({ error: 'You\'re already logged in!' }.to_json)
        )
      end
    end

    context 'when logged in on another device' do
      # Waiting on session management changes
      pending 'allows logging in on the current device' do
        post :create, params: { login: user.username, password: 'secret' }

        expect(controller).to(
          set_flash[:success].to('Logged in successfully!')
        )
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when logged out with bad credentials' do
      before do
        post :create, params: { login: user.username, password: 'wrong!' }
      end

      it 'denies access' do
        expect(controller).not_to(
          set_flash[:success].to('Logged in successfully!')
        )
        expect(response).not_to redirect_to(root_path)
      end
    end

    context 'when logged out with good credentials' do
      before do
        post :create, params: { login: user.username, password: 'secret' }
      end

      it 'allows access' do
        expect(controller).to(
          set_flash[:success].to('Logged in successfully!')
        )
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when locked out with good credentials' do
      before do
        3.times do
          post :create, params: { login: user.username, password: 'wrong!' }
        end

        post :create, params: { login: user.username, password: 'secret' }
      end

      it 'denies access' do
        expect(controller).not_to(
          set_flash[:success].to('Logged in successfully!')
        )
        expect(response).not_to redirect_to(root_path)
      end
    end

    # FIXME: These tests can probably be cleaned up somehow.
    context 'when previously locked out' do
      before do
        3.times do
          post :create, params: { login: user.username, password: 'wrong!' }
        end

        Timecop.freeze(Time.current + 2.hours)
      end

      after do
        Timecop.return
      end

      # rubocop:disable RSpec/ExampleLength
      # IMPORTANT: Prevents regression of CVE-2020-11052, do not remove.
      it 'can relock if bad credentials are given' do
        3.times do
          post :create, params: { login: user.username, password: 'wrong!' }
        end

        post :create, params: { login: user.username, password: 'secret' }

        expect(controller).not_to(
          set_flash[:success].to('Logged in successfully!')
        )
        expect(response).not_to redirect_to(root_path)
      end
      # rubocop:enable RSpec/ExampleLength

      it 'still denies access if bad credentials are given' do
        post :create, params: { login: user.username, password: 'wrong!' }

        expect(controller).not_to(
          set_flash[:success].to('Logged in successfully!')
        )
        expect(response).not_to redirect_to(root_path)
      end

      it 'allows access if correct credentials are given' do
        post :create, params: { login: user.username, password: 'secret' }

        expect(controller).to(
          set_flash[:success].to('Logged in successfully!')
        )
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
