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

    # TODO: Add test or remove placeholder
    it 'accepts plugin settings'
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

        it { is_expected.to be_falsey }
      end

      context 'when last_login_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at = Time.current - 3.hours
          record
        end

        it { is_expected.to be_truthy }
      end

      context 'when last_logout_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at  = Time.current - 3.hours
          record.last_logout_at = Time.current
          record
        end

        it { is_expected.to be_falsey }
      end
    end

    describe 'logged_out?' do
      subject(:logged_out) { record.logged_out? }

      context 'when last_login_at is nil' do
        let(:record) { user_class.new }

        it { is_expected.to be_truthy }
      end

      context 'when last_login_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at = Time.current - 3.hours
          record
        end

        it { is_expected.to be_falsey }
      end

      context 'when last_logout_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at  = Time.current - 3.hours
          record.last_logout_at = Time.current
          record
        end

        it { is_expected.to be_truthy }
      end
    end

    describe 'online?' do
      subject(:online) { record.online? }

      context 'when last_login_at is nil' do
        let(:record) { user_class.new }

        it { is_expected.to be_falsey }
      end

      context 'when last_activity_at is nil' do
        let(:record) do
          record = user_class.new
          record.last_login_at = Time.current - 3.hours
          record
        end

        it { is_expected.to be_falsey }
      end

      context 'when last_activity_at is old' do
        let(:record) do
          record = user_class.new
          record.last_login_at    = Time.current - 3.hours
          record.last_activity_at = Time.current - 2.hours
          record
        end

        it { is_expected.to be_falsey }
      end

      context 'when last_activity_at is recent' do
        let(:record) do
          record = user_class.new
          record.last_login_at    = Time.current - 3.hours
          record.last_activity_at = Time.current
          record
        end

        it { is_expected.to be_truthy }
      end

      context 'when last_logout_at is present' do
        let(:record) do
          record = user_class.new
          record.last_login_at    = Time.current - 3.hours
          record.last_activity_at = Time.current
          record.last_logout_at   = Time.current
          record
        end

        it { is_expected.to be_falsey }
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
