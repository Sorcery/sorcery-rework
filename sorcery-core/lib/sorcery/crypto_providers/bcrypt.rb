# frozen_string_literal: true

require 'bcrypt'

module Sorcery
  module CryptoProviders
    # For most apps Sha512 is plenty secure, but if you are building an app that
    # stores nuclear launch codes you might want to consider BCrypt. This is an
    # extremely secure hashing algorithm, mainly because it is slow.
    # A brute force attack on a BCrypt encrypted password would take much longer
    # than a brute force attack on a password encrypted with a Sha algorithm.
    # Keep in mind you are sacrificing performance by using this, generating a
    # password takes exponentially longer than any of the Sha algorithms.
    #
    #   config.encryption_algorithm = :bcrypt
    #
    class BCrypt
      class << self
        # Setting the option :pepper allows users to append an app-specific
        # secret token.
        # Basically it's equivalent to :salt_join_token option, but have a
        # different name to ensure backward compatibility in generating/matching
        # passwords.
        attr_accessor :pepper

        # This is the :cost option for the BCrpyt library.
        # The higher the cost the more secure it is and the longer is take the
        # generate a hash. By default this is 10.
        # Set this to whatever you want, play around with it to get that perfect
        # balance between security and performance.
        def cost
          @cost ||= 10
        end

        attr_writer :cost

        alias stretches cost
        alias stretches= cost=

        # Creates a BCrypt hash for the password passed.
        def encrypt(*tokens)
          ::BCrypt::Password.create(join_tokens(tokens), cost: cost)
        end

        # Does the hash match the tokens? Uses the same tokens that were used to
        # encrypt.
        def matches?(hash, *tokens)
          hash = new_from_hash(hash)
          return false if hash.nil? || hash == {}

          hash == join_tokens(tokens)
        end

        # This method is used as a flag to tell Sorcery to "resave" the password
        # upon a successful login, using the new cost
        def cost_matches?(hash)
          hash = new_from_hash(hash)
          if hash.nil? || hash == {}
            false
          else
            hash.cost == cost
          end
        end

        def reset!
          @cost = 10
          @pepper = ''
        end

        private

        def join_tokens(tokens)
          # Make sure to add pepper in case tokens have only one element
          tokens.flatten.join.concat(pepper.to_s)
        end

        def new_from_hash(hash)
          ::BCrypt::Password.new(hash)
        rescue ::BCrypt::Errors::InvalidHash
          nil
        end
      end
    end
  end
end
