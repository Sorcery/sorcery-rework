# frozen_string_literal: true

module Sorcery
  ##
  # Custom error class for rescuing from all Sorcery errors.
  #
  class Error < StandardError; end

  module Errors
    class ConfigError < Sorcery::Error; end

    class PluginDependencyError < ConfigError; end

    class SessionNotDestroyed < Sorcery::Error; end
  end
end
