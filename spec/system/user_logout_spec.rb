# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
# rubocop:disable RSpec/RepeatedExampleGroupBody
RSpec.describe 'User logout' do
  let(:user) { create :user, password: 'secret' }

  context 'when logged in on current device' do
    before do
      post '/user/login', params:  { login: user.username, password: 'secret' }
      byebug # session => has stuff
    end

    it 'allows logging out' do
      delete '/user/logout' # session is not being persisted between calls

      expect(flash[:success]).to eq 'Logged out successfully!'
      expect(response).to redirect_to(root_path)
    end
  end

  context 'when logged in on another device' do
    it 'prevents logging out'
  end

  context 'when logged out everywhere' do
    it 'prevents logging out'
  end
end
# rubocop:enable RSpec/DescribeClass
# rubocop:enable RSpec/RepeatedExampleGroupBody
