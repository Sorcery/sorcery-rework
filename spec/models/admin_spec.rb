# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin do
  subject(:record) { build(:admin) }

  it 'has valid factory' do
    expect(record).to be_valid
  end

  describe 'associations' do
    it { should have_one(:admin_session).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
  end

  describe 'class method' do
    describe 'authenticate' do
      subject(:admin) { create(:admin, password: 'secret') }

      it 'returns admin if credentials are good' do
        expect(described_class.authenticate(admin.email, 'secret')).to eq admin
      end

      it 'returns nil if credentials are bad' do
        expect(described_class.authenticate(admin.email, 'wrong!')).to be_nil
      end
    end
  end

  include_examples 'sorcery_orm_adapter'
end
