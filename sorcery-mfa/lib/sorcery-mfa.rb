# frozen_string_literal: true

require 'sorcery-core'

# TODO: Documentation
module Sorcery
  module Plugins
    module MFA # :nodoc:
      def self.hello_world
        "Hello from sorcery-mfa v#{Sorcery::VERSION::STRING}"
      end
    end
  end
end
