# frozen_string_literal: true

require 'sorcery-core'

module Sorcery
  module Plugins # :nodoc:
    def self.jwt_plugin_const
      :JWT
    end

    autoload :JWT, 'sorcery/plugins/jwt'
  end
end
