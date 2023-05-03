# frozen_string_literal: true

# TODO: Should this whole plugin just be deprecated? It seems like a security
#       nightmare waiting to happen.

module Sorcery
  module Plugins
    module HttpBasicAuth
      module Controller # :nodoc:
        extend Sorcery::Plugin

        def self.plugin_callbacks
          {
            # FIXME: Login source isn't a callback, but this still works...Find
            #        better naming?
            login_sources: [:login_from_basic_auth]
          }
        end

        def self.plugin_defaults
          {
            controller_to_realm_map: { 'application' => 'Application' }
          }
        end

        module InstanceMethods # :nodoc:
          protected

          ##
          # To be used as a before_action.
          # The method sets a session when requesting the user's credentials.
          # This is a trick to overcome the way HTTP authentication works
          # (explained below):
          #
          # Once the user fills the credentials once, the browser will always
          # send it to the server when visiting the website, until the browser
          # is closed. This causes wierd behaviour if the user logs out. The
          # session is reset, yet the user is re-logged in by the before_action
          # calling 'login_from_basic_auth'. To overcome this, we set a session
          # when requesting the password, which logout will reset, and that's
          # how we know if we need to request for HTTP auth again.
          #
          # rubocop:disable Layout/LineLength
          #
          def require_login_from_http_basic
            if request.authorization.nil? || session[:http_authentication_used].nil?
              request_http_basic_authentication(realm_name_by_controller)
              session[:http_authentication_used] = true
              return
            end

            require_login
            session[:http_authentication_used] = nil unless logged_in?
          end
          # rubocop:enable Layout/LineLength

          ##
          # Given to main controller module as a login source callback
          #
          # rubocop:disable Metrics/MethodLength
          #
          def login_from_basic_auth
            authenticate_with_http_basic do |username, password|
              http_basic_auth_user =
                if session[:http_authentication_used]
                  # FIXME: Wouldn't this be vulnerable to brute force attacks?
                  #        Does that matter for HTTP Basic Auth?
                  #        Also it ignores all the other login related
                  #        callbacks...I suspect this is hilariously wrong.
                  user_class.authenticate(username, password)
                else
                  false
                end

              return nil unless http_basic_auth_user

              login_as_user(http_basic_auth_user)
              # FIXME: Returning the session via the instance variable seems
              #        hacky and dangerous. Yeehaw 🤠
              return @current_sorcery_session
            end
          end

          def realm_name_by_controller
            # Map the controller_name to the realm_name.
            realm_name = sorcery_config.controller_to_realm_map[controller_name]

            # If that didn't work, try the symbol before giving up
            if realm_name.nil?
              realm_name =
                sorcery_config.controller_to_realm_map[controller_name.to_sym]
            end

            # Return the realm_name for the current controller
            return realm_name if realm_name.present?

            if defined?(super)
              # Try the parent controller's realm name until we find something.
              super
            else
              # Raise an error if we ran out of superclasses to try.
              # TODO: Include name of original controller in error message?
              raise Sorcery::Errors::ConfigError,
                'Tried to use http basic auth without a realm mapping for ' \
                'the calling controller'
            end
          end
          # rubocop:enable Metrics/MethodLength
        end
      end
    end
  end
end
