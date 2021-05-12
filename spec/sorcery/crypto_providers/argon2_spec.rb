# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

# FIXME: Find better way to handle context grouping
# rubocop:disable RSpec/NestedGroups
# TODO: Why do we care about memoized helpers?
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Sorcery::CryptoProviders::Argon2 do
  subject(:hashing_provider) { described_class.new(settings: settings) }

  let(:original_password) { Faker::Internet.unique.password }
  let(:other_password) { Faker::Internet.unique.password }
  let(:original_pepper) { 'pepper' }
  let(:other_pepper) { 'paprika' }
  # NOTE: This minimum is enforced by the Argon2 library, anything lower will
  #       result in a MEMORY_TOO_LITTLE error.
  let(:minimum_argon2_cost) { 3 }
  # Used to test changing the cost of the algorithm.
  let(:alternative_argon2_cost) { minimum_argon2_cost + 3 }
  let(:settings) { { m_cost: minimum_argon2_cost } }

  # Does testing accessors provide value?
  it { should respond_to :pepper }
  it { should respond_to :pepper= }
  it { should respond_to :t_cost }
  it { should respond_to :t_cost= }
  it { should respond_to :m_cost }
  it { should respond_to :m_cost= }
  it { should respond_to :p_cost }
  it { should respond_to :p_cost= }

  describe 'class methods' do
    describe 'digest' do
      subject(:digest) { hashing_provider.digest(original_password) }

      let(:argon2) { ::Argon2::Password.new(digest) }

      it { is_expected.to be_a String }
      it { is_expected.to be_present }

      it 'is comparable with original secret' do
        expect(argon2).to be_matches original_password
      end

      it 'has the minimum_argon2_cost' do
        expect(argon2.m_cost).to eq minimum_argon2_cost
      end

      context 'when cost is the alternative_argon2_cost' do
        let(:settings) do
          { m_cost: alternative_argon2_cost }
        end

        it 'is comparable with original secret' do
          expect(argon2).to be_matches original_password
        end

        it 'has the alternative_argon2_cost' do
          expect(argon2.m_cost).to eq alternative_argon2_cost
        end
      end

      context 'when pepper is provided' do
        let(:settings) do
          { m_cost: minimum_argon2_cost, pepper: original_pepper }
        end

        it 'is comparable with original secret with pepper appended' do
          expect(argon2).to be_matches original_password, original_pepper
        end
      end

      context 'when pepper is nil' do
        let(:settings) do
          { cost: minimum_argon2_cost, pepper: nil }
        end

        it 'is comparable with original secret with no pepper' do
          expect(argon2).to be_matches original_password
        end
      end

      context 'when pepper is an empty string' do
        let(:settings) do
          { m_cost: minimum_argon2_cost, pepper: '' }
        end

        it 'is comparable with original secret with no pepper' do
          expect(argon2).to be_matches original_password
        end
      end
    end

    describe 'digest_matches?' do
      let(:digest) do
        ::Argon2::Password.create(
          original_password,
          m_cost: minimum_argon2_cost
        )
      end

      it 'returns true when given valid password' do
        expect(hashing_provider).to be_digest_matches(digest, original_password)
      end

      it 'returns false when given invalid password' do
        expect(hashing_provider).not_to be_digest_matches(digest, other_password)
      end

      context 'when pepper is provided' do
        let(:digest) do
          ::Argon2::Password.create(
            original_password,
            m_cost: minimum_argon2_cost,
            secret: original_pepper
          )
        end

        let(:settings) do
          { m_cost: minimum_argon2_cost, pepper: original_pepper }
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
          ::Argon2::Password.create(
            original_password,
            m_cost: minimum_argon2_cost
          )
        end

        let(:settings) { { m_cost: minimum_argon2_cost, pepper: nil } }

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
          ::Argon2::Password.create(
            original_password,
            m_cost: minimum_argon2_cost
          )
        end

        let(:settings) { { m_cost: minimum_argon2_cost, pepper: '' } }

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
        ::Argon2::Password.create(
          original_password,
          m_cost: minimum_argon2_cost
        )
      end

      context 'when m_cost matches' do
        it { should_not be_needs_redigested(digest) }
      end

      context 'when m_cost does not match' do
        let(:settings) { { m_cost: alternative_argon2_cost } }

        it { should be_needs_redigested(digest) }
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
# rubocop:enable RSpec/MultipleMemoizedHelpers
