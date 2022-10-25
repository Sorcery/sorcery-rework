# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSession do
  subject(:record) { build(:user_session) }

  it 'has valid factory' do
    expect(record).to be_valid
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end
end
