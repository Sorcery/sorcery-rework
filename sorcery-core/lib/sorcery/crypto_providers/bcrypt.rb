# frozen_string_literal: true

require 'bcrypt'

module Sorcery
  module CryptoProviders
    ##
    # BCrypt is a longstanding password hashing algorithm, popular due to its
    # high computational cost, and the ability to increase that cost as
    # processors become more powerful over time.
    #
    #   config.encryption_algorithm = :bcrypt
    #
    class BCrypt
      DEFAULT_COST = 10
      DEFAULT_PEPPER = nil

      attr_accessor :pepper, :cost

      def initialize(settings: {})
        @cost   = settings[:cost]   || DEFAULT_COST
        @pepper = settings[:pepper] || DEFAULT_PEPPER
      end

      ##
      # Creates a BCrypt hash for the password provided.
      #
      def digest(password)
        password = "#{password}#{pepper}" if pepper.present?
        ::BCrypt::Password.create(password, cost: cost).to_s
      end

      ##
      # Compares a password hash (digest) with a provided plaintext password.
      #--
      # TODO: Should this check that digest and password are both strings, or
      #       is the performance hit not worth the type safety?
      #++
      #
      def digest_matches?(digest, password)
        bcrypt = bcrypt_from_digest(digest)
        return false if bcrypt.nil?

        password = "#{password}#{pepper}" if pepper.present?
        password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)

        ::Sorcery::CryptoProviders.secure_compare(bcrypt, password)
      end

      ##
      # This method is used as a flag to tell Sorcery to "resave" the password
      # upon a successful login, using the new cost.
      #
      def needs_redigested?(digest)
        bcrypt = bcrypt_from_digest(digest)
        return true if bcrypt.nil?

        # TODO: Should this also check that pepper matches?
        bcrypt.cost != cost
      end

      private

      ##
      # Converts a raw bcrypt hash into a bcrypt password object.
      #
      def bcrypt_from_digest(digest)
        ::BCrypt::Password.new(digest)
      rescue ::BCrypt::Errors::InvalidHash
        nil
      end
    end
  end
end
