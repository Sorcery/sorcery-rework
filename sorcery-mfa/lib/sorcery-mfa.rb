# frozen_string_literal: true

require 'sorcery-core'

module Sorcery
  module Plugins # :nodoc:
    def self.mfa_plugin_const
      :MFA
    end

    autoload :MFA, 'sorcery/plugins/mfa'
  end
end
