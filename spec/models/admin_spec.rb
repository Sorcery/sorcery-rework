# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin do
  subject(:record) { build :admin }

  it 'has valid factory' do
    expect(record).to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
  end
end
