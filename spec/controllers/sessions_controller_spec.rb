# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController do
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
  end
end
