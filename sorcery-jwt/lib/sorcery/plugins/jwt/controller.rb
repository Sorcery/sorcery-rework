# frozen_string_literal: true

module Sorcery
  module Plugins
    module JWT
      module Controller # :nodoc:
        module InstanceMethods

          def login_from_jwt
            session_key = decoded_token.first.slice(sorcery_config.session_key)

            @current_user = user_class.sorcery_orm_adapter.find_by_id(
              session_key
            )
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

            JWT.encode(
              payload,
              sorcery_config.jwt_secret,
              sorcery_config.jwt_algorithm
            )
          end
        end
      end
    end
  end
end
