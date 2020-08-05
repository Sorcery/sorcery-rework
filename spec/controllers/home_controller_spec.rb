# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  describe 'home' do
    it 'renders 200 ok' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'restricted' do
    context 'when logged in' do
      let(:user) { create :user }

      it 'allows access' do
        get :restricted, session: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        expect(response).not_to redirect_to(root_path)
      end
    end

    context 'when logged out' do
      it 'denies access' do
        get :restricted

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
