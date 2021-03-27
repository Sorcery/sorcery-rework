# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

# FIXME: Find better way to handle context grouping
# rubocop:disable RSpec/NestedGroups
# TODO: Why do we care about memoized helpers?
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Sorcery::CryptoProviders::BCrypt do
  let(:original_password) { Faker::Internet.unique.password }
  let(:other_password) { Faker::Internet.unique.password }
  let(:original_pepper) { 'pepper' }
  let(:other_pepper) { 'paprika' }
  # NOTE: This minimum is enforced by the BCrypt library, anything lower will
  #       automatically be upped back to 4.
  let(:minimum_bcrypt_cost) { 4 }
  # Used to test changing the cost of the algorithm.
  let(:alternative_bcrypt_cost) { 7 }

  before do
    described_class.cost = minimum_bcrypt_cost
  end

  after do
    described_class.reset_to_defaults!
  end

  it 'responds to stretches' do
    expect(described_class).to respond_to :stretches
    expect(described_class).to respond_to :stretches=
  end

  it 'responds to pepper' do
    expect(described_class).to respond_to :pepper
    expect(described_class).to respond_to :pepper=
  end

  describe 'class methods' do
    describe 'stretches' do
      subject(:alias_name) { described_class.method(:stretches).original_name }

      it 'is an alias of cost' do
        expect(alias_name).to eq described_class.method(:cost).original_name
      end

      it 'returns cost' do
        expect(described_class.stretches).to eq minimum_bcrypt_cost
      end
    end

    describe 'stretches=' do
      subject(:alias_name) { described_class.method(:stretches=).original_name }

      it 'is an alias of cost=' do
        expect(alias_name).to eq described_class.method(:cost=).original_name
      end

      # TODO: Redundant with alias name checking, remove?
      it 'sets cost' do
        expect(described_class.cost).to eq minimum_bcrypt_cost

        described_class.stretches = 5

        expect(described_class.cost).to eq 5
      end
    end

    describe 'digest' do
      subject(:digest) { described_class.digest(original_password) }

      let(:bcrypt) { ::BCrypt::Password.new(digest) }

      it { is_expected.to be_a String }
      it { is_expected.to be_present }

      it 'is comparable with original secret' do
        expect(bcrypt).to eq original_password
      end

      it 'has the minimum_bcrypt_cost' do
        expect(bcrypt.cost).to eq minimum_bcrypt_cost
      end

      context 'when cost is the alternative_bcrypt_cost' do
        subject(:digest) do
          described_class.cost = alternative_bcrypt_cost
          described_class.digest(original_password)
        end

        it 'is comparable with original secret' do
          expect(bcrypt).to eq original_password
        end

        it 'has the alternative_bcrypt_cost' do
          expect(bcrypt.cost).to eq alternative_bcrypt_cost
        end
      end

      context 'when pepper is provided' do
        subject(:digest) do
          described_class.pepper = original_pepper
          described_class.digest(original_password)
        end

        it 'is comparable with original secret with pepper appended' do
          expect(bcrypt).to eq original_password + original_pepper
        end
      end

      context 'when pepper is an empty string' do
        subject(:digest) do
          described_class.pepper = ''
          described_class.digest(original_password)
        end

        it 'is comparable with original secret with no pepper' do
          expect(bcrypt).to eq original_password
        end
      end
    end

    describe 'digest_matches?' do
      subject(:digest) do
        ::BCrypt::Password.create(original_password, cost: described_class.cost)
      end

      it 'returns true when given valid password' do
        expect(described_class).to be_digest_matches(digest, original_password)
      end

      it 'returns false when given invalid password' do
        expect(described_class).not_to be_digest_matches(digest, other_password)
      end

      context 'when pepper is provided' do
        subject(:digest) do
          ::BCrypt::Password.create(
            original_password + original_pepper,
            cost: described_class.cost
          )
        end

        # FIXME: If we set this inside the subject, it can cause a weird edge
        #        case where we set the pepper to something else, then it gets
        #        set back to the original pepper when we call `digest`.
        before do
          described_class.pepper = original_pepper
        end

        it 'returns true when given valid password' do
          expect(described_class).to(
            be_digest_matches(digest, original_password)
          )
        end

        it 'returns false when given invalid password' do
          expect(described_class).not_to(
            be_digest_matches(digest, other_password)
          )
        end

        it 'returns false when given valid password but different pepper' do
          described_class.pepper = other_pepper
          expect(described_class).not_to(
            be_digest_matches(digest, original_password)
          )
        end

        it 'returns false when given valid password and no pepper' do
          described_class.pepper = ''
          expect(described_class).not_to(
            be_digest_matches(digest, original_password)
          )
        end
      end

      context 'when pepper is an empty string (default)' do
        subject(:digest) do
          ::BCrypt::Password.create(
            original_password,
            cost: described_class.cost
          )
        end

        # FIXME: If we set this inside the subject, it can cause a weird edge
        #        case where we set the pepper to something else, then it gets
        #        set back to the original pepper when we call `digest`.
        before do
          described_class.pepper = ''
        end

        it 'returns true when given valid password' do
          expect(described_class).to(
            be_digest_matches(digest, original_password)
          )
        end

        it 'returns false when given invalid password' do
          expect(described_class).not_to(
            be_digest_matches(digest, other_password)
          )
        end

        it 'returns false when given valid password but a new pepper' do
          described_class.pepper = other_pepper
          expect(described_class).not_to(
            be_digest_matches(digest, original_password)
          )
        end
      end
    end

    describe 'cost_matches?' do
      subject(:digest) do
        ::BCrypt::Password.create(original_password, cost: minimum_bcrypt_cost)
      end

      it 'returns true when cost matches digest cost' do
        expect(described_class).to be_cost_matches(digest)
      end

      it 'returns false when cost does not match digest cost' do
        described_class.cost = alternative_bcrypt_cost
        expect(described_class).not_to be_cost_matches(digest)
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
# rubocop:enable RSpec/MultipleMemoizedHelpers
