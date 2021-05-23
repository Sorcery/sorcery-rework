# frozen_string_literal: true

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

          # rubocop:disable Layout/LineLength
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

          # TODO: Dear god, how am I going to make this accept sessions?
          def login_from_basic_auth
            authenticate_with_http_basic do |username, password|
              @current_user =
                if session[:http_authentication_used]
                  user_class.authenticate(username, password)
                else
                  false
                end

              auto_login(@current_user) if @current_user
              @current_user
            end
          end

          def realm_name_by_controller
            # Map the controller_name to the realm_name.
            realm_name = sorcery_config.controller_to_realm_map[controller_name]
            # Return the realm_name for the current controller
            return realm_name if realm_name.present?
            # Return nil if we ran out of superclasses to try.
            return nil if controller_name == 'application'

            # Try the parent controller's realm name until we find something.
            super
          end
        end
      end
    end
  end
end
