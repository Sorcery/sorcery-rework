# frozen_string_literal: true

module Sorcery
  module Plugins
    module Core # :nodoc:
      autoload :Model, 'sorcery/plugins/core/model'

      def self.hello_world
        "Hello from sorcery-core v#{Sorcery::VERSION::STRING}"
      end
    end
  end
end
