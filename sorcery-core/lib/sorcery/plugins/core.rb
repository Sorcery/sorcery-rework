# frozen_string_literal: true

# TODO: Should plugins be nested in a Plugin module? e.g. Sorcery::Plugins::Core
module Sorcery
  module Plugins
    module Core # :nodoc:
      def self.hello_world
        "Hello from sorcery-core v#{Sorcery::VERSION::STRING}"
      end
    end
  end
end
