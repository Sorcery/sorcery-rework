# frozen_string_literal: true

require 'sorcery/version'

# TODO: Documentation
module Sorcery # :nodoc:
  module Core # :nodoc:
    def self.hello_world
      "Hello from sorcery-core v#{Sorcery::VERSION::STRING}"
    end
  end
end
