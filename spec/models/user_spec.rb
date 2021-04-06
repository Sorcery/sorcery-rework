# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:record) { build :user }

  it 'has valid factory' do
    expect(record).to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
  end

  describe 'class method' do
    describe 'authenticate' do
      subject(:user) { create :user, password: 'secret' }

      it 'returns user if credentials are good' do
        expect(described_class.authenticate(user.username, 'secret')).to eq user
      end

      it 'returns nil if credentials are bad' do
        expect(described_class.authenticate(user.username, 'wrong!')).to eq nil
      end
    end

    describe 'sorcery_orm_adapter' do
      subject(:sorcery_orm_adapter) { described_class.sorcery_orm_adapter }

      it 'uses ActiveRecord' do
        expect(sorcery_orm_adapter).to eq Sorcery::OrmAdapters::ActiveRecord
      end
    end
  end

  describe 'instance method' do
    describe 'sorcery_orm_adapter' do
      subject(:sorcery_orm_adapter) { record.sorcery_orm_adapter.class }

      let(:record) { build :admin }

      it 'uses ActiveRecord' do
        expect(sorcery_orm_adapter).to eq Sorcery::OrmAdapters::ActiveRecord
      end
    end
  end

  include_examples 'activity_logging'
  include_examples 'brute_force_protection'
  include_examples 'remember_me'
end
