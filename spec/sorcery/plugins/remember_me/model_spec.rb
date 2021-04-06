# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sorcery::Plugins::RememberMe::Model do
  subject(:user_class) { Class.new { extend Sorcery::Model } }

  let(:user_instance) { user_class.new }

  describe 'user_class.authenticates_with_sorcery!' do
    it 'includes InstanceMethods on calling class instances' do
      expect(user_instance).not_to respond_to :remember_me!

      # NOTE: Calling this on the class, not instance, is intentional.
      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:remember_me)
      end

      expect(user_instance).to respond_to :remember_me!
    end

    # TODO: Add test or remove placeholder
    it 'accepts plugin settings'
  end

  # FIXME: This is pretty messy, both in terms of styling, but also breaking
  #        down the various scenarios and contexts. Ideally this should be
  #        cleaned up significantly.
  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable RSpec/MultipleExpectations
  # rubocop:disable RSpec/NestedGroups
  describe 'instance method' do
    subject(:record) { user_class.new }

    let(:user_class) do
      user_class = Class.new do
        extend Sorcery::Model

        attr_accessor(
          :remember_me_token,
          :remember_me_token_expires_at
        )
      end

      user_class.authenticates_with_sorcery! do |config|
        config.load_plugin(:remember_me)
      end

      user_class
    end

    it { is_expected.to respond_to :remember_me! }
    it { is_expected.to respond_to :forget_me! }
    it { is_expected.to respond_to :force_forget_me! }

    describe 'remember_me!' do
      context 'when persisting globally' do
        around do |example|
          prev_val = record.sorcery_config.remember_me_token_persist_globally
          record.sorcery_config.remember_me_token_persist_globally = true
          example.run
          record.sorcery_config.remember_me_token_persist_globally = prev_val
        end

        it 'generates a new token when token is nil' do
          expect(record.remember_me_token).to be_nil

          record.remember_me!

          expect(record.remember_me_token).to be_present
        end

        it 'does not generate a new token when token already exists' do
          record.remember_me!

          previous_token = record.remember_me_token

          expect(record.remember_me_token).to be_present
          expect(record.remember_me_token).to eq previous_token

          record.remember_me!

          expect(record.remember_me_token).to be_present
          expect(record.remember_me_token).to eq previous_token
        end
      end

      context 'when not persisting globally' do
        around do |example|
          prev_val = record.sorcery_config.remember_me_token_persist_globally
          record.sorcery_config.remember_me_token_persist_globally = false
          example.run
          record.sorcery_config.remember_me_token_persist_globally = prev_val
        end

        it 'generates a new token when token is nil' do
          expect(record.remember_me_token).to be_nil

          record.remember_me!

          expect(record.remember_me_token).to be_present
        end

        it 'generates a new token when token already exists' do
          record.remember_me!

          previous_token = record.remember_me_token

          expect(record.remember_me_token).to be_present
          expect(record.remember_me_token).to eq previous_token

          record.remember_me!

          expect(record.remember_me_token).to be_present
          expect(record.remember_me_token).not_to eq previous_token
        end
      end
    end

    # TODO: Update the subject to already be remembered?
    describe 'forget_me!' do
      context 'when persisting globally' do
        around do |example|
          prev_val = record.sorcery_config.remember_me_token_persist_globally
          record.sorcery_config.remember_me_token_persist_globally = true
          example.run
          record.sorcery_config.remember_me_token_persist_globally = prev_val
        end

        it 'does not delete the token' do
          record.remember_me!
          expect(record.remember_me_token).to be_present
          record.forget_me!
          expect(record.remember_me_token).to be_present
        end

        it 'does not delete the expiration' do
          record.remember_me!
          expect(record.remember_me_token_expires_at).to be_present
          record.forget_me!
          expect(record.remember_me_token_expires_at).to be_present
        end
      end

      context 'when not persisting globally' do
        around do |example|
          prev_val = record.sorcery_config.remember_me_token_persist_globally
          record.sorcery_config.remember_me_token_persist_globally = false
          example.run
          record.sorcery_config.remember_me_token_persist_globally = prev_val
        end

        it 'deletes the token' do
          record.remember_me!
          expect(record.remember_me_token).to be_present
          record.forget_me!
          expect(record.remember_me_token).to be_nil
        end

        it 'deletes the expiration' do
          record.remember_me!
          expect(record.remember_me_token_expires_at).to be_present
          record.forget_me!
          expect(record.remember_me_token_expires_at).to be_nil
        end
      end
    end

    # TODO: Update the subject to already be remembered?
    describe 'force_forget_me!' do
      context 'when persisting globally' do
        around do |example|
          prev_val = record.sorcery_config.remember_me_token_persist_globally
          record.sorcery_config.remember_me_token_persist_globally = true
          example.run
          record.sorcery_config.remember_me_token_persist_globally = prev_val
        end

        it 'deletes the token' do
          record.remember_me!
          expect(record.remember_me_token).to be_present
          record.force_forget_me!
          expect(record.remember_me_token).to be_nil
        end

        it 'deletes the expiration' do
          record.remember_me!
          expect(record.remember_me_token_expires_at).to be_present
          record.force_forget_me!
          expect(record.remember_me_token_expires_at).to be_nil
        end
      end

      context 'when not persisting globally' do
        around do |example|
          prev_val = record.sorcery_config.remember_me_token_persist_globally
          record.sorcery_config.remember_me_token_persist_globally = false
          example.run
          record.sorcery_config.remember_me_token_persist_globally = prev_val
        end

        it 'deletes the token' do
          record.remember_me!
          expect(record.remember_me_token).to be_present
          record.force_forget_me!
          expect(record.remember_me_token).to be_nil
        end

        it 'deletes the expiration' do
          record.remember_me!
          expect(record.remember_me_token_expires_at).to be_present
          record.force_forget_me!
          expect(record.remember_me_token_expires_at).to be_nil
        end
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength
  # rubocop:enable RSpec/MultipleExpectations
  # rubocop:enable RSpec/NestedGroups
end
