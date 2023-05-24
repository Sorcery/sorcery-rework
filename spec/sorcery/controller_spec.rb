# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

RSpec.describe Sorcery::Controller do
  subject(:controller_class) { Class.new { extend Sorcery::Controller } }

  let(:controller_instance) { controller_class.new }

  it 'responds to authenticates_with_sorcery!' do
    expect(controller_class).to respond_to :authenticates_with_sorcery!
  end

  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable RSpec/MultipleExpectations
  describe 'controller_class.authenticates_with_sorcery!' do
    it 'accepts core settings' do
      expect(controller_instance).not_to respond_to :sorcery_config

      # NOTE: Calling this on the class, not instance, is intentional.
      controller_class.authenticates_with_sorcery! do |config|
        config.user_class = 'TestUser'
        config.not_authenticated_action = :my_action
      end

      expect(controller_instance.sorcery_config.user_class).to be('TestUser')
      expect(
        controller_instance.sorcery_config.not_authenticated_action
      ).to be(:my_action)
    end

    it 'includes InstanceMethods on calling class instances' do
      expect(controller_instance).not_to respond_to :login
      expect(controller_instance).not_to respond_to :logout
      expect(controller_instance).not_to respond_to :logged_in?
      expect(controller_instance).not_to respond_to :current_user
      expect(controller_instance).not_to respond_to :require_login
      expect(controller_instance).not_to respond_to :login_as_user

      # NOTE: Calling this on the class, not instance, is intentional.
      controller_class.authenticates_with_sorcery!

      expect(controller_instance).to respond_to :login
      expect(controller_instance).to respond_to :logout
      expect(controller_instance).to respond_to :logged_in?
      expect(controller_instance).to respond_to :current_user
      expect(controller_instance).to respond_to :require_login
      expect(controller_instance).to respond_to :login_as_user
    end
  end
  # rubocop:enable RSpec/ExampleLength
  # rubocop:enable RSpec/MultipleExpectations
end
