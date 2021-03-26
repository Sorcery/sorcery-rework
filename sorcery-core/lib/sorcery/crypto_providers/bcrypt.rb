# frozen_string_literal: true

require 'bcrypt'

module Sorcery
  module CryptoProviders
    ##
    # BCrypt is one of the longstanding password hasing algorithms, popular due
    # to its higher computational cost, and the ability to increase that cost
    # as processors become more powerful over time. While perfectly suitable for
    # applications at the time of writing (2021), Argon2 is a more recent
    # algorithm, and should be preferred for new projects.
    #
    #   config.encryption_algorithm = :bcrypt
    #
    class BCrypt
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
        # This value is used to control BCrypt's computational cost. The higher
        # this value is, the longer it will take to generate a hash, which makes
        # the hash more secure against brute force attacks in the case of a
        # database breach.
        #
        # The default value is 10. You can set this to whatever you want, a rule
        # of thumb you can use is getting the hash generation to take about
        # 100ms on production. This keeps the user experience reasonable, while
        # being a reasonably high per-attempt value.
        #
        # If you're not sure what a good value for this is, do a search or open
        # a Github issue to ask.
        #
        def cost
          @cost ||= 10
        end

        attr_writer :cost

        ##
        # Stretches is another applicable term for the cost.
        #
        alias stretches cost
        alias stretches= cost=

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
          # TODO: Is checking against {} necessary? Why do we do this?
          return false if bcrypt.nil? || bcrypt == {}

          password = "#{password}#{pepper}" if pepper.present?
          password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)

          ::Sorcery::CryptoProviders.secure_compare(bcrypt, password)
        end

        ##
        # This method is used as a flag to tell Sorcery to "resave" the password
        # upon a successful login, using the new cost.
        #--
        # TODO: Update this to a "needs_redigested?" type method instead, that
        #       checks all bcrypt params for changes.
        #++
        #
        def cost_matches?(digest)
          bcrypt = bcrypt_from_digest(digest)
          # TODO: Is checking against {} necessary? Why do we do this?
          return false if bcrypt.nil? || bcrypt == {}

          bcrypt.cost == cost
        end

        ##
        # Resets cost and pepper to their default values
        #
        def reset_to_defaults!
          @cost = 10
          @pepper = ''
        end

        private

        ##
        # Converts a raw bcrypt hash into a bcrypt password object.
        #
        def bcrypt_from_digest(digest)
          # TODO: Is this guard clause necessary? Won't it just get caught by
          #       bcrypt because a blank string is an invalid bcrypt hash?
          return nil if digest.blank?

          ::BCrypt::Password.new(digest)
        rescue ::BCrypt::Errors::InvalidHash
          nil
        end
      end
    end
  end
end
