# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-mfa'

RSpec.describe Sorcery::Plugins::MFA do
  it 'says hello world' do
    expect(described_class.hello_world).to eq 'Hello from sorcery-mfa v0.0.0'
  end
end
