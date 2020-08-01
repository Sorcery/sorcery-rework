# frozen_string_literal: true

require 'rails_helper'

# TODO: Test that the Railtie will load even without calling it directly. e.g.
#       in a typical Rails application use-case.
RSpec.describe Sorcery::Railtie do
  describe 'ActionController::API' do
    subject(:base_class) { Class.new(ActionController::API) }

    it 'automatically extends Sorcery::Controller' do
      expect(base_class).to respond_to :authenticates_with_sorcery!
    end
  end

  describe 'ActionController::Base' do
    subject(:base_class) { Class.new(ActionController::Base) }

    it 'automatically extends Sorcery::Controller' do
      expect(base_class).to respond_to :authenticates_with_sorcery!
    end
  end

  describe 'ActiveRecord::Base' do
    subject(:base_class) { Class.new(ActiveRecord::Base) }

    it 'automatically extends Sorcery::Model' do
      expect(base_class).to respond_to :authenticates_with_sorcery!
    end
  end
end
