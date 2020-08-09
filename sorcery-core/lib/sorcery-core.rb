# frozen_string_literal: true

##
# Sorcery is a stripped-down, bare-bones authentication library, with which you
# can write your own authentication flow. It was built with a few goals in mind:
#
# * Less is more - As few public methods as possible, to make Sorcery easy to
#   'get'.
# * No built-in or generated code - Use the library's methods inside *your own*
#   MVC structures, and don't fight to fix someone else's.
# * Magic Yes, Voodoo no - Sorcery should be easy to hack for most developers.
# * Keep MVC cleanly separated - DB is for models, sessions are for controllers.
#   Models stay unaware of sessions.
#
module Sorcery
  ####################################
  ## Add Autoload Paths for Sorcery ##
  ####################################
  autoload :Config, 'sorcery/config'
  autoload :Controller, 'sorcery/controller'
  autoload :Error, 'sorcery/error' # TODO: Should this be a require?
  autoload :Model, 'sorcery/model'
  autoload :VERSION, 'sorcery/version'

  ##
  # Password crypto providers
  #
  module CryptoProviders
    autoload :Argon2, 'sorcery/crypto_providers/argon2'
    autoload :BCrypt, 'sorcery/crypto_providers/bcrypt'
  end

  ##
  # ORM adapter abstraction layer.
  #
  module OrmAdapters
    autoload :ActiveRecord, 'sorcery/orm_adapters/active_record'
    autoload :Base, 'sorcery/orm_adapters/base'
  end

  ##
  # Plugins are self-contained units of code that extend Sorcery to provide
  # functionality that may not be needed in all use-cases. You can create gems
  # that act as Sorcery plugins, see `sorcery-mfa` and `sorcery-oauth` for
  # examples on how to approach this.
  #
  module Plugins
    autoload :ActivityLogging, 'sorcery/plugins/activity_logging'
    autoload :BruteForceProtection, 'sorcery/plugins/brute_force_protection'
    autoload :RememberMe, 'sorcery/plugins/brute_force_protection'
    autoload :ResetPassword, 'sorcery/plugins/brute_force_protection'
    autoload :UserActivation, 'sorcery/plugins/brute_force_protection'
  end

  ###############################
  ## Extend Rails with Sorcery ##
  ###############################
  require 'sorcery/railtie'
end
