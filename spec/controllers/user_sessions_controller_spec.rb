# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSessionsController do
  let(:user) { create :user, password: 'secret' }

  describe 'new' do
    context 'when logged in' do
      before { get :new, session: { user_id: user.id } }

      it 'prevents logging in twice' do
        expect(controller).to set_flash[:error].to 'You\'re already logged in!'
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when logged out' do
      before { get :new }

      it 'allows logging in' do
        expect(controller).not_to(
          set_flash[:error].to('You\'re already logged in!')
        )
        expect(response).not_to redirect_to(root_path)
      end
    end
  end

  describe 'create' do
    context 'when logged in' do
      before do
        post :create,
          params:  { login: user.username, password: 'secret' },
          session: { user_id: user.id }
      end

      it 'prevents logging in twice' do
        expect(controller).to set_flash[:error].to 'You\'re already logged in!'
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when logged in on another device' do
      # Waiting on session management changes
      it 'allows logging in on the current device' do
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
