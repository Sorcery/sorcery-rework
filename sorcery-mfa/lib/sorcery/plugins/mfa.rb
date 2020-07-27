# frozen_string_literal: true

module Sorcery
  module Plugins
    module MFA # :nodoc:
      autoload :Model, 'sorcery/plugins/mfa/model'

      def self.hello_world
        "Hello from sorcery-mfa v#{Sorcery::VERSION::STRING}"
      end
    end
  end
end
