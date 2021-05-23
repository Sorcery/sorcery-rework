# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
# rubocop:disable RSpec/RepeatedExampleGroupBody
RSpec.describe 'User logout' do
  let(:user) { create :user, password: 'secret' }

  context 'when logged in on current device' do
    before do
      post '/user/login', params: { login: user.username, password: 'secret' }
    end

    it 'allows logging out' do
      delete '/user/logout'

      expect(flash[:success]).to eq 'Logged out successfully!'
      expect(response).to redirect_to(root_path)
    end
  end

  context 'when logged out after logging in' do
    before do
      post '/user/login', params: { login: user.username, password: 'secret' }
      delete '/user/logout'
    end

    it 'prevents access to restricted pages' do
      get '/restricted'

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end
  end

  context 'when logged in on another device' do
    let!(:other_session) { create :user_session, user: user }

    it 'prevents logging out' do
      delete '/user/logout'

      expect(flash[:alert]).to eq 'Please login first.'
      expect(response).to redirect_to(root_path)
    end
  end

  context 'when logged out everywhere' do
    it 'prevents logging out' do
      delete '/user/logout'

      expect(flash[:alert]).to eq 'Please login first.'
      expect(response).to redirect_to(root_path)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
# rubocop:enable RSpec/RepeatedExampleGroupBody
