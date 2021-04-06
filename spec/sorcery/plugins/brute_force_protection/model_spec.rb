# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

RSpec.describe Sorcery::Plugins::BruteForceProtection::Model do
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

  # rubocop:disable RSpec/NestedGroups
  describe 'instance method' do
    let(:user_class) do
      user_class = Class.new do
        extend Sorcery::Model

        attr_accessor :lock_expires_at
      end

      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:brute_force_protection)
      end

      user_class
    end

    describe 'login_locked?' do
      context 'when locked' do
        subject(:record) do
          record = user_class.new
          record.lock_expires_at = Time.current + 5.days
          record
        end

        it 'returns true' do
          expect(record).to be_login_locked
        end
      end

      context 'when unlocked' do
        subject(:record) do
          record = user_class.new
          record.lock_expires_at = nil
          record
        end

        it 'returns false' do
          expect(record).not_to be_login_locked
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
