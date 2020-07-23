# frozen_string_literal: true

require 'sorcery-core'

# TODO: Documentation
module Sorcery
  module Plugins
    module OAuth # :nodoc:
      def self.hello_world
        "Hello from sorcery-oauth v#{Sorcery::VERSION::STRING}"
      end
    end
  end
end
