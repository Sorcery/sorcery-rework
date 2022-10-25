# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminSession do
  subject(:record) { build(:admin_session) }

  it 'has valid factory' do
    expect(record).to be_valid
  end

  describe 'associations' do
    it { should belong_to(:admin) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:admin_id) }
  end
end
