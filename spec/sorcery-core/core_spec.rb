# frozen_string_literal: true

# FIXME: This feels hyperjank. Consider better ways to break down specs into
#        logical chunks.

require 'core_helper'

RSpec.describe Sorcery::Core do
  it 'says hello world' do
    expect(Sorcery::Core.hello_world).to eq 'Hello from sorcery-core v0.0.0'
  end
end
