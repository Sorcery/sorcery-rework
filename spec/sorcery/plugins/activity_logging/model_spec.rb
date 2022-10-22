# frozen_string_literal: true

require 'rails_helper'

# require 'spec_helper'
# require 'sorcery-core'

RSpec.describe Sorcery::Plugins::ActivityLogging::Model do
  subject(:user_class) { Class.new { extend Sorcery::Model } }

  let(:user_instance) { user_class.new }

  describe 'user_class.authenticates_with_sorcery!' do
    it 'includes InstanceMethods on calling class instances' do
      expect(user_instance).not_to respond_to :recently_active?

      # NOTE: Calling this on the class, not instance, is intentional.
      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:activity_logging)
      end

      expect(user_instance).to respond_to :recently_active?
    end

    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it 'accepts plugin settings' do
      expect(user_instance).not_to respond_to :sorcery_config

      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(
          :activity_logging,
          model: {
            last_login_at_attr_name:         :my_last_login_at,
            last_logout_at_attr_name:        :my_last_logout_at,
            last_activity_at_attr_name:      :my_last_activity_at,
            last_login_from_ip_address_name: :my_last_login_from_ip_address,
            activity_timeout:                1337
          }
        )
      end

      expect(
        user_instance.sorcery_config.last_login_at_attr_name
      ).to be(:my_last_login_at)
      expect(
        user_instance.sorcery_config.last_logout_at_attr_name
      ).to be(:my_last_logout_at)
      expect(
        user_instance.sorcery_config.last_activity_at_attr_name
      ).to be(:my_last_activity_at)
      expect(
        user_instance.sorcery_config.last_login_from_ip_address_name
      ).to be(:my_last_login_from_ip_address)
      expect(
        user_instance.sorcery_config.activity_timeout
      ).to be(1337)
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable RSpec/MultipleExpectations
  end

  # rubocop:disable RSpec/NestedGroups
  describe 'instance method' do
    let(:user_class) do
      user_class = Class.new do
        extend Sorcery::Model

        attr_accessor(
          :last_login_at,
          :last_logout_at,
          :last_activity_at,
          :last_login_from_ip_address
        )
      end

      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:activity_logging)
      end

      user_class
    end

    describe 'logged_in?' do
      subject(:logged_in) { record.logged_in? }

      context 'when last_login_at is nil' do
        let(:record) { user_class.new }

        it { should be_falsey }
      end

      context 'when last_login_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at = Time.current - 3.hours
          record
        end

        it { should be_truthy }
      end

      context 'when last_logout_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at  = Time.current - 3.hours
          record.last_logout_at = Time.current
          record
        end

        it { should be_falsey }
      end
    end

    describe 'logged_out?' do
      subject(:logged_out) { record.logged_out? }

      context 'when last_login_at is nil' do
        let(:record) { user_class.new }

        it { should be_truthy }
      end

      context 'when last_login_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at = Time.current - 3.hours
          record
        end

        it { should be_falsey }
      end

      context 'when last_logout_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at  = Time.current - 3.hours
          record.last_logout_at = Time.current
          record
        end

        it { should be_truthy }
      end
    end

    describe 'online?' do
      subject(:online) { record.online? }

      context 'when last_login_at is nil' do
        let(:record) { user_class.new }

        it { should be_falsey }
      end

      context 'when last_activity_at is nil' do
        let(:record) do
          record = user_class.new
          record.last_login_at = Time.current - 3.hours
          record
        end

        it { should be_falsey }
      end

      context 'when last_activity_at is old' do
        let(:record) do
          record = user_class.new
          record.last_login_at    = Time.current - 3.hours
          record.last_activity_at = Time.current - 2.hours
          record
        end

        it { should be_falsey }
      end

      context 'when last_activity_at is recent' do
        let(:record) do
          record = user_class.new
          record.last_login_at    = Time.current - 3.hours
          record.last_activity_at = Time.current
          record
        end

        it { should be_truthy }
      end

      context 'when last_logout_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at    = Time.current - 3.hours
          record.last_activity_at = Time.current
          record.last_logout_at   = Time.current
          record
        end

        it { should be_falsey }
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
