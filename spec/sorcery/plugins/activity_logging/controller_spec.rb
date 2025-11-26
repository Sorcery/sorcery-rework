# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sorcery::Plugins::ActivityLogging::Controller do
  # FIXME: This doesn't work without ActionController due to not responding to
  #        the `after_action` method.
  subject(:controller_class) { Class.new(ActionController::Base) }

  let(:controller_instance) { controller_class.new }

  describe 'controller_class.authenticates_with_sorcery!' do
    # rubocop:disable RSpec/ExampleLength
    it 'accepts plugin settings' do
      expect(controller_instance).not_to respond_to :sorcery_config

      # NOTE: Calling this on the class, not instance, is intentional.
      controller_class.authenticates_with_sorcery! do |config|
        config.load_plugin(
          :activity_logging,
          controller: { register_login_time: false }
        )
      end

      expect(
        controller_instance.sorcery_config.register_login_time
      ).to be(false)
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe 'instance method' do
    let(:controller_class) do
      controller_class = Class.new(ActionController::Base)

      controller_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:activity_logging, controller: test_config)
      end

      controller_class
    end

    subject(:controller_instance) { controller_class.new }

    let(:test_config) { {} }
    let(:username) { Faker::Internet.username }
    let(:password) { Faker::Internet.password }
    # TODO: Should this use a stub instead of the dummy app factory?
    let!(:user) { create(:user, username: username, password: password) }

    describe 'login' do
      context 'when register_login_time is true' do
        let(:test_config) { { register_login_time: true } }

        it 'logs login time' do
          expect(user.last_login_at).to be_nil

          controller_instance.login(username, password)

          expect(user.last_login_at).to be_present
        end
      end

      context 'when register_login_time is false' do
        let(:test_config) { { register_login_time: false } }

        it 'does not log login time' do
          expect(user.last_login_at).to be_nil

          controller_instance.login(username, password)

          expect(user.last_login_at).to be_nil
        end
      end
    end
  end
end
