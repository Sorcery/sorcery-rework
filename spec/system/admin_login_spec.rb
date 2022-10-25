# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/RepeatedExampleGroupBody
RSpec.describe 'Admin login' do
  let(:admin) { create(:admin, password: 'secret') }

  context 'when logged in on current device' do
    it 'prevents logging in twice'
  end

  context 'when logged in on another device' do
    it 'prevents logging in on second device'
  end

  context 'when logged out everywhere' do
    context 'with good credentials' do
      it 'allows logging in'
    end

    context 'with bad credentials' do
      it 'prevents logging in'
    end
  end

  context 'when locked out of account' do
    context 'with good credentials' do
      it 'prevents logging in'
    end

    context 'with bad credentials' do
      it 'prevents logging in'
    end
  end

  context 'when previously locked out of account' do
    # IMPORTANT: Prevents regression of CVE-2020-11052, do not remove.
    it 'can relock if another brute force is attempted'
    it 'still denies access if bad credentials are given'
    it 'allows access if good credentials are given'
  end
end
# rubocop:enable RSpec/RepeatedExampleGroupBody
