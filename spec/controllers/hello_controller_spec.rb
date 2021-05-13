# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HelloController do
  describe 'hello' do
    it 'renders 200 ok' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq({ hello: 'there' }.to_json)
    end
  end

  describe 'restricted' do
    context 'when logged in' do
      let(:user) { create :user }
      let(:session) { create :user_session, user: user }

      it 'allows access' do
        request.headers['Authorization'] = create_sorcery_jwt_session(user)
        get :restricted

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({ restricted: 'content here' }.to_json)
      end
    end

    context 'when logged out' do
      it 'denies access' do
        get :restricted

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq({ error: 'Please login first.' }.to_json)
      end
    end
  end
end
