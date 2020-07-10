# frozen_string_literal: true

require 'mfa_helper'

RSpec.describe Sorcery::MFA do
  it 'says hello world' do
    expect(described_class.hello_world).to eq 'Hello from sorcery-mfa v0.0.0'
  end
end
