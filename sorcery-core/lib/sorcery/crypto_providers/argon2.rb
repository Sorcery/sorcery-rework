# frozen_string_literal: true

require 'argon2'

module Sorcery
  module CryptoProviders
    ##
    # TODO: Argon2 description
    #
    #   config.encryption_algorithm = :argon2
    #
    class Argon2
      DEFAULT_PEPPER = nil
      DEFAULT_T_COST = 2
      DEFAULT_M_COST = 16
      DEFAULT_P_COST = 1

      attr_accessor :pepper, :t_cost, :m_cost, :p_cost

      def initialize(settings: {})
        @pepper = settings[:pepper] || DEFAULT_PEPPER
        @t_cost = settings[:t_cost] || DEFAULT_T_COST
        @m_cost = settings[:m_cost] || DEFAULT_M_COST
        @p_cost = settings[:p_cost] || DEFAULT_P_COST
      end

      ##
      # Creates an Argon2 hash for the password provided.
      #
      def digest(password)
        ::Argon2::Password.create(
          password,
          t_cost: t_cost,
          m_cost: m_cost,
          p_cost: p_cost,
          secret: pepper
        ).to_s
      end

      ##
      # Compares a password hash (digest) with a provided plaintext password.
      #
      def digest_matches?(digest, password)
        ::Argon2::Password.verify_password(password, digest, pepper)
      end

      ##
      # This method is used as a flag to tell Sorcery to "resave" the password
      # upon a successful login, using the new cost.
      #
      def needs_redigested?(digest)
        argon2 = argon2_from_digest(digest)
        return true if argon2.nil?

        # TODO: Should this also check that pepper matches?
        argon2.t_cost != t_cost ||
        argon2.m_cost != m_cost ||
        argon2.p_cost != p_cost
      end

      private

      ##
      # Converts a raw argon2 hash into an argon2 password object.
      #
      def argon2_from_digest(digest)
        ::Argon2::Password.new(digest)
      rescue ::Argon2::Errors::InvalidHash
        nil
      end
    end
  end
end
