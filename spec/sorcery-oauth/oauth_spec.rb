# frozen_string_literal: true

require 'oauth_helper'

RSpec.describe Sorcery::OAuth do
  it 'says hello world' do
    expect(Sorcery::OAuth.hello_world).to eq 'Hello from sorcery-oauth v0.0.0'
  end
end
