# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

RSpec.describe Sorcery::Plugins::ActivityLogging do
  describe 'controllers' do
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
        ).to eq(false)
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe 'models' do
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

      it 'accepts plugin settings' do
      end
    end
  end
end
