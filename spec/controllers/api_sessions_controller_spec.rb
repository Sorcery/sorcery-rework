# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiSessionsController do
  let(:user) { create(:user, password: 'secret') }

  describe 'create' do
    context 'when logged in' do
      let!(:headers) do
        token = controller.login_as_user(user)
        # FIXME: Controller specs don't reset instance vars between calls
        controller.remove_instance_variable(:@current_user)
        controller.remove_instance_variable(:@current_sorcery_session)
        {
          'Authorization' => "Bearer #{token}"
        }
      end

      # rubocop:disable RSpec/ExampleLength
      it 'prevents logging in twice' do
        request.headers.merge! headers
        post :create, params: { login: user.username, password: 'secret' }

        expect(response).to have_http_status :bad_request
        expect(response.body).to(
          eq({ error: 'You\'re already logged in!' }.to_json)
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when logged in on another device' do
      before do
        post :create, params: { login: user.username, password: 'secret' }
        # FIXME: Controller specs don't reset instance vars between calls
        controller.remove_instance_variable(:@current_user)
        controller.remove_instance_variable(:@current_sorcery_session)
      end

      it 'allows logging in on the current device' do
        post :create, params: { login: user.username, password: 'secret' }

        expect(response).to have_http_status :ok
        token = JSON.parse(response.body)['session_token']
        expect(token).to be_present
      end
    end

    context 'when logged out with bad credentials' do
      it 'denies access' do
        post :create, params: { login: user.username, password: 'wrong!' }

        expect(response).to have_http_status :bad_request
        expect(response.body).to(
          eq({ error: 'Failed to login' }.to_json)
        )
      end
    end

    context 'when logged out with good credentials' do
      it 'allows access' do
        post :create, params: { login: user.username, password: 'secret' }

        expect(response).to have_http_status :ok
        token = JSON.parse(response.body)['session_token']
        expect(token).to be_present
      end
    end

    context 'when locked out with good credentials' do
      before do
        3.times do
          post :create, params: { login: user.username, password: 'wrong!' }
        end
      end

      it 'denies access' do
        post :create, params: { login: user.username, password: 'secret' }

        expect(response).to have_http_status :bad_request
        expect(response.body).to(
          eq({ error: 'Failed to login' }.to_json)
        )
      end
    end

    # FIXME: These tests can probably be cleaned up somehow.
    context 'when previously locked out' do
      before do
        3.times do
          post :create, params: { login: user.username, password: 'wrong!' }
        end

        Timecop.freeze(Time.current + 2.hours)
      end

      after do
        Timecop.return
      end

      # rubocop:disable RSpec/ExampleLength
      # IMPORTANT: Prevents regression of CVE-2020-11052, do not remove.
      it 'can relock if bad credentials are given' do
        3.times do
          post :create, params: { login: user.username, password: 'wrong!' }
        end

        post :create, params: { login: user.username, password: 'secret' }

        expect(response).to have_http_status :bad_request
        expect(response.body).to(
          eq({ error: 'Failed to login' }.to_json)
        )
      end
      # rubocop:enable RSpec/ExampleLength

      it 'still denies access if bad credentials are given' do
        post :create, params: { login: user.username, password: 'wrong!' }

        expect(response).to have_http_status :bad_request
        expect(response.body).to(
          eq({ error: 'Failed to login' }.to_json)
        )
      end

      it 'allows access if correct credentials are given' do
        post :create, params: { login: user.username, password: 'secret' }

        expect(response).to have_http_status :ok
        token = JSON.parse(response.body)['session_token']
        expect(token).to be_present
      end
    end
  end
end
