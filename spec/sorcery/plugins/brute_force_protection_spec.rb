# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

RSpec.describe Sorcery::Plugins::BruteForceProtection do
  subject(:user_class) { Class.new { extend Sorcery::Model } }

  let(:user_instance) { user_class.new }

  describe 'user_class.authenticates_with_sorcery!' do
    it 'extends ClassMethods to calling class' do
      expect(user_class).not_to respond_to :load_from_unlock_token

      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:brute_force_protection)
      end

      expect(user_class).to respond_to :load_from_unlock_token
    end

    it 'includes InstanceMethods on calling class instances' do
      expect(user_instance).not_to respond_to :register_failed_login!

      # NOTE: Calling this on the class, not instance, is intentional.
      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:brute_force_protection)
      end

      expect(user_instance).to respond_to :register_failed_login!
    end
  end
end
