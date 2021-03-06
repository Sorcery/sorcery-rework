# frozen_string_literal: true

require 'spec_helper'
require 'sorcery-oauth'

RSpec.describe Sorcery::Plugins::OAuth do
  it 'says hello world' do
    expect(described_class.hello_world).to eq 'Hello from sorcery-oauth v0.0.0'
  end
end
