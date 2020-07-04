require 'sorcery/version'

module Sorcery
  module Core
    def self.hello_world
      "Hello from sorcery-core v#{Sorcery::VERSION::STRING}"
    end
  end
end
