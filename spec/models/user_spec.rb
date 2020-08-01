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
end
