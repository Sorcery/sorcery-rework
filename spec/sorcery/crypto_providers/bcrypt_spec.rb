# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

# FIXME: Find better way to handle context grouping
# rubocop:disable RSpec/NestedGroups
# TODO: Why do we care about memoized helpers?
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Sorcery::CryptoProviders::BCrypt do
  subject(:hashing_provider) { described_class.new(settings: settings) }

  let(:original_password) { Faker::Internet.unique.password }
  let(:other_password) { Faker::Internet.unique.password }
  let(:original_pepper) { 'pepper' }
  let(:other_pepper) { 'paprika' }
  # NOTE: This minimum is enforced by the BCrypt library, anything lower will
  #       automatically be upped back to 4.
  let(:minimum_bcrypt_cost) { 4 }
  # Used to test changing the cost of the algorithm.
  let(:alternative_bcrypt_cost) { minimum_bcrypt_cost + 3 }
  let(:settings) { { cost: minimum_bcrypt_cost } }

  # Does testing accessors provide value?
  it { should respond_to :pepper }
  it { should respond_to :pepper= }
  it { should respond_to :cost }
  it { should respond_to :cost= }

  describe 'class methods' do
    describe 'digest' do
      subject(:digest) { hashing_provider.digest(original_password) }

      let(:bcrypt) { BCrypt::Password.new(digest) }

      it { should be_a String }
      it { should be_present }

      it 'is comparable with original secret' do
        expect(bcrypt).to eq original_password
      end

      it 'has the minimum_bcrypt_cost' do
        expect(bcrypt.cost).to eq minimum_bcrypt_cost
      end

      context 'when cost is the alternative_bcrypt_cost' do
        let(:settings) do
          { cost: alternative_bcrypt_cost }
        end

        it 'is comparable with original secret' do
          expect(bcrypt).to eq original_password
        end

        it 'has the alternative_bcrypt_cost' do
          expect(bcrypt.cost).to eq alternative_bcrypt_cost
        end
      end

      context 'when pepper is provided' do
        let(:settings) do
          { cost: minimum_bcrypt_cost, pepper: original_pepper }
        end

        it 'is comparable with original secret with pepper appended' do
          expect(bcrypt).to eq original_password + original_pepper
        end
      end

      context 'when pepper is nil' do
        let(:settings) do
          { cost: minimum_bcrypt_cost, pepper: nil }
        end

        it 'is comparable with original secret with no pepper' do
          expect(bcrypt).to eq original_password
        end
      end

      context 'when pepper is an empty string' do
        let(:settings) do
          { cost: minimum_bcrypt_cost, pepper: '' }
        end

        it 'is comparable with original secret with no pepper' do
          expect(bcrypt).to eq original_password
        end
      end
    end

    describe 'digest_matches?' do
      let(:digest) do
        BCrypt::Password.create(
          original_password,
          cost: minimum_bcrypt_cost
        )
      end

      it 'returns true when given valid password' do
        expect(hashing_provider).to be_digest_matches(digest, original_password)
      end

      it 'returns false when given invalid password' do
        expect(hashing_provider).not_to(
          be_digest_matches(digest, other_password)
        )
      end

      context 'when pepper is provided' do
        let(:digest) do
          BCrypt::Password.create(
            original_password + original_pepper,
            cost: minimum_bcrypt_cost
          )
        end

        let(:settings) do
          { cost: minimum_bcrypt_cost, pepper: original_pepper }
        end

        it 'returns true when given valid password' do
          expect(hashing_provider).to(
            be_digest_matches(digest, original_password)
          )
        end

        it 'returns false when given invalid password' do
          expect(hashing_provider).not_to(
            be_digest_matches(digest, other_password)
          )
        end

        it 'returns false when given valid password but different pepper' do
          hashing_provider.pepper = other_pepper
          expect(hashing_provider).not_to(
            be_digest_matches(digest, original_password)
          )
        end

        it 'returns false when given valid password and no pepper' do
          hashing_provider.pepper = nil
          expect(hashing_provider).not_to(
            be_digest_matches(digest, original_password)
          )
        end
      end

      context 'when pepper is nil (default)' do
        subject(:digest) do
          BCrypt::Password.create(
            original_password,
            cost: minimum_bcrypt_cost
          )
        end

        let(:settings) { { cost: minimum_bcrypt_cost, pepper: nil } }

        it 'returns true when given valid password' do
          expect(hashing_provider).to(
            be_digest_matches(digest, original_password)
          )
        end

        it 'returns false when given invalid password' do
          expect(hashing_provider).not_to(
            be_digest_matches(digest, other_password)
          )
        end

        it 'returns false when given valid password but a new pepper' do
          hashing_provider.pepper = other_pepper
          expect(hashing_provider).not_to(
            be_digest_matches(digest, original_password)
          )
        end
      end

      context 'when pepper is an empty string' do
        subject(:digest) do
          BCrypt::Password.create(
            original_password,
            cost: minimum_bcrypt_cost
          )
        end

        let(:settings) { { cost: minimum_bcrypt_cost, pepper: '' } }

        it 'returns true when given valid password' do
          expect(hashing_provider).to(
            be_digest_matches(digest, original_password)
          )
        end

        it 'returns false when given invalid password' do
          expect(hashing_provider).not_to(
            be_digest_matches(digest, other_password)
          )
        end

        it 'returns false when given valid password but a new pepper' do
          hashing_provider.pepper = other_pepper
          expect(hashing_provider).not_to(
            be_digest_matches(digest, original_password)
          )
        end
      end
    end

    describe 'needs_redigested?' do
      let(:digest) do
        BCrypt::Password.create(
          original_password,
          cost: minimum_bcrypt_cost
        )
      end

      context 'when cost matches' do
        it { should_not be_needs_redigested(digest) }
      end

      context 'when cost does not match' do
        let(:settings) { { cost: alternative_bcrypt_cost } }

        it { should be_needs_redigested(digest) }
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
# rubocop:enable RSpec/MultipleMemoizedHelpers
