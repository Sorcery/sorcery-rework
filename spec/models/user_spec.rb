# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:record) { build(:user) }

  it 'has valid factory' do
    expect(record).to be_valid
  end

  describe 'associations' do
    it { should have_many(:user_sessions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:username) }
  end

  describe 'class method' do
    describe 'authenticate' do
      subject(:user) { create(:user, password: 'secret') }

      it 'returns user if credentials are good' do
        expect(described_class.authenticate(user.username, 'secret')).to eq user
      end

      it 'returns nil if credentials are bad' do
        expect(described_class.authenticate(user.username, 'wrong!')).to be_nil
      end
    end
  end

  include_examples 'sorcery_orm_adapter'
end
