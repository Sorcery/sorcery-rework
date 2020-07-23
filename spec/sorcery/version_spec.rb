# frozen_string_literal: true

require 'core_helper'

RSpec.describe Sorcery::VERSION do
  it 'provides a string of current version' do
    expect(described_class::STRING).to be_a String
  end

  describe 'Sorcery.gem_version' do
    subject { Sorcery.gem_version }

    it 'returns a Gem::Version object' do
      expect(subject).to be_a Gem::Version
    end

    it 'matches Sorcery::VERSION' do
      expect(subject).to eq Gem::Version.new(described_class::STRING)
    end
  end
end
