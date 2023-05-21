# frozen_string_literal: true

module ModelSpecHelper
  # Ensure that the sorcery_orm_adapter is being properly set to ActiveRecord
  RSpec.shared_examples 'sorcery_orm_adapter' do
    subject(:record) { build(class_symbol) }

    let(:class_symbol) { described_class.name.underscore.to_sym }

    describe 'sorcery_orm_adapter' do
      describe 'class method' do
        subject(:sorcery_orm_adapter) { described_class.sorcery_orm_adapter }

        it 'uses ActiveRecord' do
          expect(sorcery_orm_adapter).to eq Sorcery::OrmAdapters::ActiveRecord
        end
      end

      describe 'instance method' do
        subject(:sorcery_orm_adapter) { record.sorcery_orm_adapter.class }

        let(:record) { build(:admin) }

        it 'uses ActiveRecord' do
          expect(sorcery_orm_adapter).to eq Sorcery::OrmAdapters::ActiveRecord
        end
      end
    end
  end

  RSpec.shared_examples 'user_activation' do
    subject(:record) { create(class_symbol, email: Faker::Internet.email) }

    let(:class_symbol) { described_class.name.underscore.to_sym }

    describe 'user_activation' do
      describe 'class method' do
        describe 'load_from_activation_token' do
          context 'when the user is pending activation' do
            before do
              record.setup_activation
              record.save!
            end

            it 'loads the user from the token' do
              expect(
                described_class.load_from_activation_token(record.activation_token)
              ).to eq record
            end
          end

          context 'when the user is activated' do
            before do
              record.setup_activation
              record.save!
              record.activate!
            end

            it 'does not find the user' do
              expect(
                described_class.load_from_activation_token(record.activation_token)
              ).to be_nil
            end
          end
        end
      end

      describe 'instance method' do
        describe 'setup_activation' do
          it 'sets activation_token to a random token' do
            expect(record.activation_token).to be_nil
            record.setup_activation
            expect(record.activation_token).to be_present
          end

          it 'sets activation_state to "pending"' do
            expect(record.activation_state).to be_nil
            record.setup_activation
            expect(record.activation_state).to eq 'pending'
          end
        end

        describe 'activate!' do
          before do
            record.setup_activation
          end

          it 'sets activation_state to "active"' do
            expect(record.activation_state).to eq 'pending'
            record.activate!
            expect(record.activation_state).to eq 'active'
          end

          it 'clears activation token' do
            expect(record.activation_token).to be_present
            record.activate!
            expect(record.activation_token).to be_nil
          end
        end
      end
    end
  end
end
