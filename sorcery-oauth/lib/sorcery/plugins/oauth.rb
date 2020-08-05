# frozen_string_literal: true

module Sorcery
  module Plugins
    module OAuth # :nodoc:
      autoload :Controller, 'sorcery/plugins/oauth/controller'
      autoload :Model, 'sorcery/plugins/oauth/model'

      def self.hello_world
        "Hello from sorcery-oauth v#{Sorcery::VERSION::STRING}"
      end
    end
  end
end
