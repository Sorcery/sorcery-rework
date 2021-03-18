# frozen_string_literal: true

# TODO: Find a better way to break this up?
# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/ModuleLength
module ModelSpecHelper
  RSpec.shared_examples 'activity_logging' do
    let(:class_symbol) { described_class.name.underscore.to_sym }
    let(:last_login_at_attr_name) do
      described_class.sorcery_config.last_login_at_attribute_name
    end
    let(:last_logout_at_attr_name) do
      described_class.sorcery_config.last_logout_at_attribute_name
    end
    let(:last_activity_at_attr_name) do
      described_class.sorcery_config.last_activity_at_attribute_name
    end

    describe 'instance method' do
      describe 'logged_in?' do
        subject(:logged_in) { record.logged_in? }

        context 'when last_login_at is nil' do
          let(:record) { build class_symbol }

          it { is_expected.to be_falsey }
        end

        context 'when last_login_at is present' do
          let(:record) do
            record = build class_symbol
            record.send("#{last_login_at_attr_name}=", Time.current - 3.hours)
            record
          end

          it { is_expected.to be_truthy }
        end

        context 'when last_logout_at is present' do
          let(:record) do
            record = build class_symbol
            record.send("#{last_login_at_attr_name}=",  Time.current - 3.hours)
            record.send("#{last_logout_at_attr_name}=", Time.current)
            record
          end

          it { is_expected.to be_falsey }
        end
      end

      describe 'logged_out?' do
        subject(:logged_out) { record.logged_out? }

        context 'when last_login_at is nil' do
          let(:record) { build class_symbol }

          it { is_expected.to be_truthy }
        end

        context 'when last_login_at is present' do
          let(:record) do
            record = build class_symbol
            record.send("#{last_login_at_attr_name}=", Time.current - 3.hours)
            record
          end

          it { is_expected.to be_falsey }
        end

        context 'when last_logout_at is present' do
          let(:record) do
            record = build class_symbol
            record.send("#{last_login_at_attr_name}=",  Time.current - 3.hours)
            record.send("#{last_logout_at_attr_name}=", Time.current)
            record
          end

          it { is_expected.to be_truthy }
        end
      end

      describe 'online?' do
        subject(:online) { record.online? }

        context 'when last_login_at is nil' do
          let(:record) { build class_symbol }

          it { is_expected.to be_falsey }
        end

        context 'when last_activity_at is nil' do
          let(:record) do
            record = build class_symbol
            record.send("#{last_login_at_attr_name}=", Time.current - 3.hours)
            record
          end

          it { is_expected.to be_falsey }
        end

        context 'when last_activity_at is old' do
          let(:record) do
            record = build class_symbol
            record.send("#{last_login_at_attr_name}=",
              Time.current - 3.hours)
            record.send("#{last_activity_at_attr_name}=",
              Time.current - 2.hours)
            record
          end

          it { is_expected.to be_falsey }
        end

        context 'when last_activity_at is recent' do
          let(:record) do
            record = build class_symbol
            record.send("#{last_login_at_attr_name}=",
              Time.current - 3.hours)
            record.send("#{last_activity_at_attr_name}=",
              Time.current)
            record
          end

          it { is_expected.to be_truthy }
        end

        context 'when last_logout_at is present' do
          let(:record) do
            record = build class_symbol
            record.send("#{last_login_at_attr_name}=",
              Time.current - 3.hours)
            record.send("#{last_activity_at_attr_name}=",
              Time.current)
            record.send("#{last_logout_at_attr_name}=",
              Time.current)
            record
          end

          it { is_expected.to be_falsey }
        end
      end
    end
  end

  RSpec.shared_examples 'brute_force_protection' do
    let(:class_symbol) { described_class.name.underscore.to_sym }
    let(:lock_expires_at_attr_name) do
      described_class.sorcery_config.lock_expires_at_attribute_name
    end

    describe 'instance method' do
      describe 'login_locked?' do
        context 'when locked' do
          subject(:record) do
            record = build class_symbol
            record.send("#{lock_expires_at_attr_name}=", Time.current + 5.days)
            record
          end

          it 'returns true' do
            expect(record).to be_login_locked
          end
        end

        context 'when unlocked' do
          subject(:record) do
            record = build class_symbol
            record.send("#{lock_expires_at_attr_name}=", nil)
            record
          end

          it 'returns false' do
            expect(record).not_to be_login_locked
          end
        end
      end
    end
  end

  # FIXME: This is pretty messy, both in terms of styling, but also breaking
  #        down the various scenarios and contexts. Ideally this should be
  #        cleaned up significantly.
  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable RSpec/MultipleExpectations
  RSpec.shared_examples 'remember_me' do
    subject(:record) { build class_symbol }

    let(:class_symbol) { described_class.name.underscore.to_sym }

    it { is_expected.to respond_to :remember_me! }
    it { is_expected.to respond_to :forget_me! }
    it { is_expected.to respond_to :force_forget_me! }

    describe 'instance method' do
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
  end
  # rubocop:enable RSpec/ExampleLength
  # rubocop:enable RSpec/MultipleExpectations
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/ModuleLength
