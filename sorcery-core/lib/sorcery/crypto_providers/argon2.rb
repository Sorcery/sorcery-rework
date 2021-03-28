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
      class << self
        ##
        # Setting the option :pepper allows users to append an app-specific
        # secret token to all passwords. While the salt is stored alongside the
        # password, the pepper is kept separate from the database, typically in
        # the source code of the application.
        #--
        # TODO: Is using the method that Devise uses for appending pepper to
        #       the password ideal? ("#{pw}#{pepper}"), or can we simplify to
        #       something like password += pepper?
        #++
        #
        attr_accessor :pepper

        ##
        # This value is used to control Argon2's computational cost. The higher
        # this value is, the longer it will take to generate a hash, which makes
        # the hash more secure against brute force attacks in the case of a
        # database breach.
        #
        # The default value is 16. You can set this to whatever you want, a rule
        # of thumb you can use is getting the hash generation to take about
        # 100ms on production. This keeps the user experience reasonable, while
        # being a reasonably high per-attempt value.
        #
        # If you're not sure what a good value for this is, do a search or open
        # a Github issue to ask.
        #
        def cost
          @cost ||= 16
        end

        attr_writer :cost

        ##
        # Stretches is another applicable term for the cost.
        #
        alias stretches cost
        alias stretches= cost=

        ##
        # Creates an Argon2 hash for the password provided.
        #
        def digest(password)
          ::Argon2::Password.create(password, m_cost: cost, secret: pepper).to_s
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
        # Comparator provided by @technion
        #--
        # TODO: Update this to a "needs_redigested?" type method instead, that
        #       checks all argon2 params for changes.
        #++
        #
        def cost_matches?(digest)
          argon2 = argon2_from_digest(digest)

          return false if argon2.nil?

          argon2.m_cost == cost
        end

        ##
        # Resets cost and pepper to their default values
        #
        def reset_to_defaults!
          @cost = 16
          @pepper = ''
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
end
