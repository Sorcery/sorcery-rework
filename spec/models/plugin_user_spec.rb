# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PluginUser do
  subject(:record) { build(:plugin_user) }

  it 'has valid factory' do
    expect(record).to be_valid
  end

  describe 'associations' do
    it { should have_many(:plugin_user_sessions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
  end

  include_examples 'user_activation'
end
