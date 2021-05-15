# frozen_string_literal: true

require 'jwt'

module Sorcery
  module Plugins
    module JWT
      module Controller # :nodoc:
        extend Sorcery::Plugin

        def self.plugin_callbacks
          {
            after_config: [:validate_jwt_secret_defined],
            login_sources: [:login_from_jwt]
          }
        end

        def self.plugin_defaults
          {
            # Secret used to encode JWTs. Should correspond to the type needed
            # by the algorithm used.
            jwt_algorithm: 'HS256',
            # Type of the algorithm used to encode JWTs. Corresponds to the
            # options available in jwt/ruby-jwt.
            jwt_session_expiry: (60 * 60 * 24 * 7 * 2), # 2 weeks
            # How long the session should be valid for in seconds. Will be set
            # as the exp claim in the token.
            jwt_secret: nil
          }
        end

        module ClassMethods
          def validate_jwt_secret_defined
            return unless sorcery_config.jwt_secret.nil?

            raise Sorcery::Errors::ConfigError,
              'A secret must be configured when using the Sorcery::Jwt '\
              'extension.'
          end
        end

        module InstanceMethods # :nodoc:
          def login_from_jwt
            session_key = decoded_token.first.slice(sorcery_config.session_key)

            @current_user = user_class.sorcery_orm_adapter.find_by_id(
              session_key
            )
          rescue ::JWT::DecodeError, ::JWT::ExpiredSignature
            @current_user = nil
            false
          end

          def create_sorcery_jwt_session(user)
            @current_user = user
            issue_jwt_token(
              { sorcery_config.session_key => @current_user.id.to_s }
            )
          end

          def issue_jwt_token(payload)
            payload =
              {
                exp: Time.current.to_i + sorcery_config.jwt_session_expiry
              }.merge(payload)

            ::JWT.encode(
              payload,
              sorcery_config.jwt_secret,
              sorcery_config.jwt_algorithm
            )
          end

          private

          # Turns "Bearer <token>" into just the token
          def token
            return nil unless authorization_header

            authorization_header.split(' ').last
          end

          def authorization_header
            @authorization_header ||= request.headers['Authorization']
          end

          def decoded_token
            ::JWT.decode(
              token,
              sorcery_config.jwt_secret,
              true, # Verify signature => true
              algorithm: sorcery_config.jwt_algorithm
            )
          end
        end
      end
    end
  end
end
