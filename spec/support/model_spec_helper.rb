# frozen_string_literal: true

# TODO: Find a better way to break this up?
# rubocop:disable Metrics/BlockLength
module ModelSpecHelper
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
end
# rubocop:enable Metrics/BlockLength
