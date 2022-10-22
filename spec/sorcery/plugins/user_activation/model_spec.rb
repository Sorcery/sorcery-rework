# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sorcery::Plugins::UserActivation::Model do
  subject(:user_class) { Class.new { extend Sorcery::Model } }

  let(:user_instance) { user_class.new }

  describe 'user_class.authenticates_with_sorcery!' do
    # rubocop:disable RSpec/ExampleLength
    it 'includes InstanceMethods on calling class instances' do
      expect(user_instance).not_to respond_to :setup_activation

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
    end

    # rubocop:disable RSpec/MultipleExpectations
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
end
