# frozen_string_literal: true

require 'sorcery-core'

# TODO: Documentation
module Sorcery
  module OAuth # :nodoc:
    def self.hello_world
      "Hello from sorcery-mfa v#{Sorcery::VERSION::STRING}"
    end
  end
end
