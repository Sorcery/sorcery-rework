# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

RSpec.describe Sorcery::Controller do
  subject(:controller_class) { Class.new { extend Sorcery::Controller } }

  let(:controller_instance) { controller_class.new }

  it 'responds to authenticates_with_sorcery!' do
    expect(controller_class).to respond_to :authenticates_with_sorcery!
  end

  describe 'controller_class.authenticates_with_sorcery!' do
    it 'includes InstanceMethods on calling class instances' do
      expect(controller_instance).not_to respond_to :current_user

      # NOTE: Calling this on the class, not instance, is intentional.
      controller_class.authenticates_with_sorcery!

      expect(controller_instance).to respond_to :current_user
    end
  end
end
