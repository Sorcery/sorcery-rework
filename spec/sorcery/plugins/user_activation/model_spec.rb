# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sorcery::Plugins::UserActivation::Model do
  subject(:user_class) { Class.new { extend Sorcery::Model } }

  let(:user_instance) { user_class.new }

  describe 'user_class.authenticates_with_sorcery!' do
    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it 'includes InstanceMethods on calling class instances' do
      expect(user_instance).not_to respond_to :setup_activation
      expect(user_instance).not_to respond_to :activate!

      # NOTE: Calling this on the class, not instance, is intentional.
      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(
          :user_activation,
          model: {
            activation_mailer_disabled: true
          }
        )
      end

      expect(user_instance).to respond_to :setup_activation
      expect(user_instance).to respond_to :activate!
    end

    # rubocop:disable Layout/LineLength
    it 'accepts plugin settings' do
      expect(user_instance).not_to respond_to :sorcery_config

      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(
          :user_activation,
          model: {
            activation_state_attr_name:            :my_activation_state,
            activation_token_attr_name:            :my_activation_token,
            activation_token_expires_at_attr_name: :my_activation_token_expires_at,
            activation_token_expiration_period:    1337,
            user_activation_mailer:                nil,
            activation_mailer_disabled:            true,
            activation_needed_email_method_name:   :my_activation_needed_email,
            activation_success_email_method_name:  :my_activation_success_email,
            prevent_non_active_users_to_login:     false
          }
        )
      end

      expect(
        user_instance.sorcery_config.activation_state_attr_name
      ).to be(:my_activation_state)
      expect(
        user_instance.sorcery_config.activation_token_attr_name
      ).to be(:my_activation_token)
      expect(
        user_instance.sorcery_config.activation_token_expires_at_attr_name
      ).to be(:my_activation_token_expires_at)
      expect(
        user_instance.sorcery_config.activation_token_expiration_period
      ).to be(1337)
      expect(
        user_instance.sorcery_config.user_activation_mailer
      ).to be_nil
      expect(
        user_instance.sorcery_config.activation_mailer_disabled
      ).to be(true)
      expect(
        user_instance.sorcery_config.activation_needed_email_method_name
      ).to be(:my_activation_needed_email)
      expect(
        user_instance.sorcery_config.activation_success_email_method_name
      ).to be(:my_activation_success_email)
      expect(
        user_instance.sorcery_config.prevent_non_active_users_to_login
      ).to be(false)
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable RSpec/MultipleExpectations
    # rubocop:enable Layout/LineLength
  end

  # rubocop:disable RSpec/ExampleLength
  context 'when activation mailer is enabled but nil' do
    it 'raises a ConfigError' do
      expect do
        user_class.authenticates_with_sorcery! do |config|
          config.load_plugin(
            :user_activation,
            model: {
              user_activation_mailer:     nil,
              activation_mailer_disabled: false
            }
          )
        end
      end.to raise_error(Sorcery::Errors::ConfigError)
    end
  end

  context 'when activation mailer is disabled and nil' do
    it 'does not raise an exception' do
      expect do
        user_class.authenticates_with_sorcery! do |config|
          config.load_plugin(
            :user_activation,
            model: {
              user_activation_mailer:     nil,
              activation_mailer_disabled: true
            }
          )
        end
      end.not_to raise_error
    end
  end
  # rubocop:enable RSpec/ExampleLength

  # rubocop:disable RSpec/EmptyExampleGroup
  describe 'instance method' do
    let(:user_class) do
      user_class = Class.new do
        extend Sorcery::Model
      end

      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:user_activation)
      end

      user_class
    end

    describe 'activate!'
    describe 'authenticate'
  end
  # rubocop:enable RSpec/EmptyExampleGroup
end
