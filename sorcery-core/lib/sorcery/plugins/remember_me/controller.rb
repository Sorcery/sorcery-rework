# frozen_string_literal: true

module Sorcery
  module Plugins
    module RememberMe
      ##
      # The Remember Me plugin takes care of setting the user's cookie so that
      # they will be automatically logged in to the site on every visit, until
      # the cookie expires.
      #
      module Controller
        extend Sorcery::Plugin

        def self.plugin_callbacks
          {
            login_sources:             [:login_from_cookie],
            before_logout:             [:forget_me!],
            before_unverified_request: [:clear_remember_me_token],
            after_login:               [:auto_remember!]
          }
        end

        def self.plugin_defaults
          {
            cookie_domain:        nil,
            remember_me_httponly: true
          }
        end

        module InstanceMethods # :nodoc:
          ##
          # This method sets the cookie and calls the user to save the token and
          # the expiration to db.
          #
          def remember_me!
            current_user.remember_me!
            set_remember_me_cookie!(current_user)
          end

          ##
          # Clears the cookie, and depending on the value of
          # remember_me_token_persist_globally, may clear the token value.
          #
          def forget_me!
            current_user.forget_me!
            cookies.delete(
              :remember_me_token,
              domain: sorcery_config.cookie_domain
            )
          end

          ##
          # Clears the cookie, and clears the token value.
          #
          def force_forget_me!
            current_user.force_forget_me!
            cookies.delete(
              :remember_me_token,
              domain: sorcery_config.cookie_domain
            )
          end

          ##
          # Before unverified request callback
          #
          def clear_remember_me_token
            # TODO: Why does this use cookies, shouldn't it be session?
            cookies[:remember_me_token] = nil
          end

          ##
          # After login callback
          #
          # TODO: if in API mode, should this auto request a refresh token?
          #
          def auto_remember!(_user, _username, _password, options)
            options = { should_remember: false }.merge(options)
            return unless options[:should_remember] == true

            remember_me!
          end

          protected

          ##
          # Checks the cookie for a remember me token, tried to find a user with
          # that token and logs the user in if found.
          # Runs as a login source. See 'current_user' method for how it is
          # used.
          #--
          # TODO: This used to set @current_user to false, this may be a
          #       breaking change. Double check that no side-effects are caused
          #       by this change, once confirmed fix and/or remove this note.
          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/MethodLength
          #++
          #
          def login_from_cookie
            # TODO: Can this be return nil instead?
            return false unless defined?(cookies)
            return false unless cookies.signed[:remember_me_token].present?

            # TODO: Simplify/DRY to:
            #       `sorcery_orm_adapter.find_by(remember_me_token:`
            user =
              user_class.sorcery_orm_adapter.find_by_remember_me_token(
                cookies.signed[:remember_me_token]
              )

            return false unless user&.remember_me_token?

            set_remember_me_cookie!(user)
            session[sorcery_config.session_key] = user.id.to_s
            after_remember_me!(user)
            @current_user = user
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          # TODO: Rename method or fix design pattern
          # rubocop:disable Naming/AccessorMethodName
          def set_remember_me_cookie!(user)
            cookies.signed[:remember_me_token] = {
              value:    user.send(
                user.sorcery_config.remember_me_token_attr_name
              ),
              expires:  user.send(
                user.sorcery_config.remember_me_token_expires_at_attr_name
              ),
              httponly: sorcery_config.remember_me_httponly,
              domain:   sorcery_config.cookie_domain
            }
          end
          # rubocop:enable Naming/AccessorMethodName
        end
      end
    end
  end
end
