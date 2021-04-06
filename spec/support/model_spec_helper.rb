# frozen_string_literal: true

module ModelSpecHelper
  # Ensure that the sorcery_orm_adapter is being properly set to ActiveRecord
  RSpec.shared_examples 'sorcery_orm_adapter' do
    subject(:record) { build class_symbol }

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

        let(:record) { build :admin }

        it 'uses ActiveRecord' do
          expect(sorcery_orm_adapter).to eq Sorcery::OrmAdapters::ActiveRecord
        end
      end
    end
  end
end
