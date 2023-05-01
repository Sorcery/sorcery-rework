# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityLoggingController do
  let(:username) { Faker::Internet.username }
  let(:password) { Faker::Internet.password }
  let!(:user) { create(:user, username: username, password: password) }

  describe 'login' do
    ##########################
    ## Config Enabled Tests ##
    ##########################

    context 'when register_login_time is true' do
      around do |example|
        prev_val = described_class.sorcery_config.register_login_time
        described_class.sorcery_config.register_login_time = true
        example.run
        described_class.sorcery_config.register_login_time = prev_val
      end

      it 'logs login time on login' do
        expect(user.last_login_at).to be_nil

        post :create, params: { login: username, password: password }

        # FIXME: Is there a way to auto reload?
        user.reload
        expect(user.last_login_at).to be_present
      end
    end

    context 'when register_logout_time is true' do
      around do |example|
        prev_val = described_class.sorcery_config.register_logout_time
        described_class.sorcery_config.register_logout_time = true
        example.run
        described_class.sorcery_config.register_logout_time = prev_val
      end

      before do
        post :create, params: { login: username, password: password }
      end

      it 'logs logout time on logout' do
        expect(user.last_logout_at).to be_nil

        delete :destroy

        # FIXME: Is there a way to auto reload?
        user.reload
        expect(user.last_logout_at).to be_present
      end
    end

    context 'when register_last_activity_time is true' do
      around do |example|
        prev_val = described_class.sorcery_config.register_last_activity_time
        described_class.sorcery_config.register_last_activity_time = true
        example.run
        described_class.sorcery_config.register_last_activity_time = prev_val
      end

      it 'logs last activity time when logged in' do
        expect(user.last_activity_at).to be_nil

        post :create, params: { login: username, password: password }

        # FIXME: Is there a way to auto reload?
        user.reload
        expect(user.last_activity_at).to be_present
      end
    end

    context 'when register_last_ip_address is true' do
      around do |example|
        prev_val = described_class.sorcery_config.register_last_ip_address
        described_class.sorcery_config.register_last_ip_address = true
        example.run
        described_class.sorcery_config.register_last_ip_address = prev_val
      end

      it 'logs last IP address when logged in' do
        expect(user.last_login_from_ip_address).to be_nil

        post :create, params: { login: username, password: password }

        # FIXME: Is there a way to auto reload?
        user.reload
        expect(user.last_login_from_ip_address).to be_present
      end
    end

    ###########################
    ## Config Disabled Tests ##
    ###########################

    context 'when register_login_time is false' do
      around do |example|
        prev_val = described_class.sorcery_config.register_login_time
        described_class.sorcery_config.register_login_time = false
        example.run
        described_class.sorcery_config.register_login_time = prev_val
      end

      it 'does not register login time' do
        expect(user.last_login_at).to be_nil

        post :create, params: { login: username, password: password }

        # FIXME: Is there a way to auto reload?
        user.reload
        expect(user.last_login_at).to be_nil
      end
    end

    context 'when register_logout_time is false' do
      around do |example|
        prev_val = described_class.sorcery_config.register_logout_time
        described_class.sorcery_config.register_logout_time = false
        example.run
        described_class.sorcery_config.register_logout_time = prev_val
      end

      before do
        post :create, params: { login: username, password: password }
      end

      it 'does not register logout time' do
        expect(user.last_logout_at).to be_nil

        delete :destroy

        # FIXME: Is there a way to auto reload?
        user.reload
        expect(user.last_logout_at).to be_nil
      end
    end

    context 'when register_last_activity_time is false' do
      around do |example|
        prev_val = described_class.sorcery_config.register_last_activity_time
        described_class.sorcery_config.register_last_activity_time = false
        example.run
        described_class.sorcery_config.register_last_activity_time = prev_val
      end

      it 'does not register last activity time' do
        expect(user.last_activity_at).to be_nil

        post :create, params: { login: username, password: password }

        # FIXME: Is there a way to auto reload?
        user.reload
        expect(user.last_activity_at).to be_nil
      end
    end

    context 'when register_last_ip_address is false' do
      around do |example|
        prev_val = described_class.sorcery_config.register_last_ip_address
        described_class.sorcery_config.register_last_ip_address = false
        example.run
        described_class.sorcery_config.register_last_ip_address = prev_val
      end

      it 'does not register last IP address' do
        expect(user.last_login_from_ip_address).to be_nil

        post :create, params: { login: username, password: password }

        # FIXME: Is there a way to auto reload?
        user.reload
        expect(user.last_login_from_ip_address).to be_nil
      end
    end
  end
end
