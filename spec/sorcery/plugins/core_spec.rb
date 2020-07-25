# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-core'

RSpec.describe Sorcery::Plugins::Core do
  it 'says hello world' do
    expect(described_class.hello_world).to eq 'Hello from sorcery-core v0.0.0'
  end
end
