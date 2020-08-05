# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

RSpec.describe Sorcery::Model do
  subject(:user_class) { Class.new { extend Sorcery::Model } }

  let(:user_instance) { user_class.new }

  it 'responds to authenticates_with_sorcery!' do
    expect(user_class).to respond_to :authenticates_with_sorcery!
  end

  # TODO: Change rubocop to allow max 2 expectations? (before/after checking)
  describe 'user_class.authenticates_with_sorcery!' do
    it 'extends ClassMethods to calling class' do
      expect(user_class).not_to respond_to :authenticate

      user_class.authenticates_with_sorcery!

      expect(user_class).to respond_to :authenticate
    end

    it 'includes InstanceMethods on calling class instances' do
      expect(user_instance).not_to respond_to :sorcery_config

      # NOTE: Calling this on the class, not instance, is intentional.
      user_class.authenticates_with_sorcery!

      expect(user_instance).to respond_to :sorcery_config
    end
  end
end
