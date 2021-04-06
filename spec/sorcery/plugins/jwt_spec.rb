# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-jwt'

RSpec.describe Sorcery::Plugins::JWT do
  it 'says hello world' do
    expect(described_class.hello_world).to eq 'Hello from sorcery-jwt v0.0.0'
  end
end
