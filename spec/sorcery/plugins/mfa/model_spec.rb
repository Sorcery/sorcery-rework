# frozen_string_literal: true

require 'rails_helper'

# require 'spec_helper'
# require 'sorcery-core'

RSpec.describe Sorcery::Plugins::MFA::Model do
  subject(:user_class) { Class.new { extend Sorcery::Model } }

  let(:user_instance) { user_class.new }

  describe 'user_class.authenticates_with_sorcery!' do
    it 'includes InstanceMethods on calling class instances' do
      # NOTE: Calling this on the class, not instance, is intentional.
      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:mfa)
      end
    end
  end
end
