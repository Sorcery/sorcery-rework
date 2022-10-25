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
      let(:user) { create(:user) }

      it 'allows access' do
        # FIXME: Should be able to set directly to login_as_user value?
        request.headers['Authorization'] =
          "Bearer #{controller.login_as_user(user)}"
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
