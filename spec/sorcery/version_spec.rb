# frozen_string_literal: true

require 'core_helper'

RSpec.describe Sorcery::VERSION do
  it 'provides a string of current version' do
    expect(described_class::STRING).to be_a String
  end
end
