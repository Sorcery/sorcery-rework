# frozen_string_literal: true

module Sorcery
  module Plugins
    ##
    # Placeholder plugin to test plugin loading. This will be removed once
    # actual plugins are ported from the existing Sorcery codebase.
    #
    module Core
      autoload :Controller, 'sorcery/plugins/core/controller'
      autoload :Model, 'sorcery/plugins/core/model'

      def self.hello_world
        "Hello from sorcery-core v#{Sorcery::VERSION::STRING}"
      end
    end
  end
end
