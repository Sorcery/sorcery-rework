require 'rails_helper'

RSpec.describe 'API Logout' do
  let(:user) { create :user, password: 'secret' }

  context 'when logged in on current device' do
    let!(:headers) do
      post '/api/login', params: { login: user.username, password: 'secret' }
      token = JSON.parse(response.body)['session_token']
      {
        'Authorization' => "Bearer #{token}"
      }
    end

    it 'allows logging out' do
      delete '/api/logout', headers: headers

      expect(response).to have_http_status :ok
      expect(response.body).to be_empty
    end
  end

  context 'when logged out after logging in', focus: true do
    let!(:headers) do
      post '/api/login', params: { login: user.username, password: 'secret' }
      token = JSON.parse(response.body)['session_token']
      {
        'Authorization' => "Bearer #{token}"
      }
    end

    before do
      delete '/api/logout', headers: headers
    end

    it 'prevents access to restricted pages' do
      # Token should be able to be revoked by logout
      get '/api/restricted', headers: headers

      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to eq({ error: 'Please login first.' }.to_json)
    end
  end

  context 'when logged in on another device' do
    let!(:other_session) { create :user_session, user: user }

    it 'prevents logging out' do
      delete '/api/logout'

      expect(flash[:alert]).to eq 'Please login first.'
      expect(response).to redirect_to(root_path)
    end
  end

  context 'when logged out everywhere' do
    it 'prevents logging out' do
      delete '/api/logout'

      expect(flash[:alert]).to eq 'Please login first.'
      expect(response).to redirect_to(root_path)
    end
  end
end
