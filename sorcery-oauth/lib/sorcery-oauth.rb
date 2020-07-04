require 'sorcery-core'

module Sorcery
  module OAuth
    def self.hello_world
      "Hello from sorcery-mfa v#{Sorcery::VERSION::STRING}"
    end
  end
end
