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
  # Password crypto providers and related methods.
  #
  module CryptoProviders
    ##
    # Provides a comparison method that attempts to protect against timing
    # attacks.
    #
    # Based on the Devise secure_compare, which itself appears to be based on
    # the rails secure_compare fallback when OpenSSL secure compare is
    # unavailable.
    #
    # For additional information, see the following documentation:
    #
    # * https://apidock.com/ruby/String/bytesize
    # * https://apidock.com/ruby/String/each_byte
    # * https://apidock.com/ruby/String/unpack
    #
    # `^`  Is a binary XOR operator. It will return only the bits that are on
    #      one side and not the other.
    # `|=` Is a binary OR operator and assignment. It will copy any bits if they
    #      exist on either side of the operator. Used to persist if we find any
    #      bytes that are different between the two strings.
    #
    #--
    # TODO: Where is the best place for this method to live?
    #++
    #
    def self.secure_compare(str1, str2)
      # Forcibly cast to String
      str1 = str1.to_s
      str2 = str2.to_s
      # Skip comparison if either string is empty
      return false if str1.blank? || str2.blank?
      # Skip comparison if the string lengths (in bytes) don't match
      return false if str1.bytesize != str2.bytesize

      # TODO: Verify that this description is accurate to what's happening here.
      # Unpack the `a` string into 8-bit unsigned chars, according to the
      # bytesize length of the string.
      unpacked_str1 = str1.unpack("C#{str1.bytesize}")

      # Start with a clean slate.
      difference = 0

      # Some binary operator magic, see method description.
      str2.each_byte do |byte|
        difference |= byte ^ unpacked_str1.shift
      end

      # If all the bits in our variable are 0, then the strings were identical.
      difference.zero?
    end

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
    autoload :RememberMe, 'sorcery/plugins/remember_me'
    autoload :ResetPassword, 'sorcery/plugins/reset_password'
    autoload :UserActivation, 'sorcery/plugins/user_activation'
  end

  ###############################
  ## Extend Rails with Sorcery ##
  ###############################
  require 'sorcery/railtie'
end
