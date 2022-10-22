# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sorcery::Plugins::ResetPassword::Model do
  subject(:user_class) { Class.new { extend Sorcery::Model } }

  let(:user_instance) { user_class.new }

  describe 'user_class.authenticates_with_sorcery!' do
    # rubocop:disable RSpec/ExampleLength
    it 'includes InstanceMethods on calling class instances' do
      expect(user_instance).not_to respond_to :generate_reset_password_token!

      # NOTE: Calling this on the class, not instance, is intentional.
      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(
          :reset_password,
          model: {
            reset_password_mailer_disabled: true
          }
        )
      end

      expect(user_instance).to respond_to :generate_reset_password_token!
    end

    it 'accepts plugin settings' do
      expect(user_instance).not_to respond_to :sorcery_config

      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(
          :reset_password,
          model: {
            reset_password_mailer_disabled: true,
            reset_password_token_attr_name: :my_reset_password_token
          }
        )
      end

      expect(
        user_instance.sorcery_config.reset_password_token_attr_name
      ).to be(:my_reset_password_token)
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
