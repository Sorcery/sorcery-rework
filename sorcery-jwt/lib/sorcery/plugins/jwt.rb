# frozen_string_literal: true

module Sorcery
  module Plugins
    module JWT # :nodoc:
      autoload :Controller, 'sorcery/plugins/jwt/controller'
      autoload :Model, 'sorcery/plugins/jwt/model'

      def self.hello_world
        "Hello from sorcery-jwt v#{Sorcery::VERSION::STRING}"
      end
    end
  end
end
