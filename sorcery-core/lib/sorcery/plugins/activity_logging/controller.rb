# frozen_string_literal: true

module Sorcery
  module Plugins
    module ActivityLogging
      ##
      # This adds the controller methods necessary to track user activity, and
      # automatically creates callbacks to collect events.
      #
      # For additional configuration options, see:
      # Sorcery::Plugins::ActivityLogging::Model
      #
      module Controller
        #--
        # rubocop:disable Metrics/MethodLength
        #++
        def self.included(base)
          base.send(:include, InstanceMethods)

          base.sorcery_config.add_plugin_defaults(
            register_login_time:         true,
            register_logout_time:        true,
            register_last_activity_time: true,
            register_last_ip_address:    true
          )

          base.sorcery_config.after_login   << :register_login_time_to_db
          base.sorcery_config.after_login   << :register_last_ip_address
          base.sorcery_config.before_logout << :register_logout_time_to_db

          base.after_action :register_last_activity_time_to_db
        end
        # rubocop:enable Metrics/MethodLength

        ##
        # TODO
        #
        module InstanceMethods
          protected

          #################
          ## after_login ##
          #################

          # registers last login time on every login.
          # This runs as a hook just after a successful login.
          def register_login_time_to_db(user, _credentials)
            return unless sorcery_config.register_login_time

            user.set_last_login_at(Time.current)
          end

          # Updates IP address on every login.
          # This runs as a hook just after a successful login.
          def register_last_ip_address(user, _credentials)
            return unless sorcery_config.register_last_ip_address

            user.set_last_ip_address(request.remote_ip)
          end

          ###################
          ## before_logout ##
          ###################

          # registers last logout time on every logout.
          # This runs as a hook just before a logout.
          def register_logout_time_to_db
            return unless sorcery_config.register_logout_time

            current_user.set_last_logout_at(Time.current)
          end

          ##################
          ## after_action ##
          ##################

          # Updates last activity time on every request.
          # The only exception is logout - we do not update activity on logout
          def register_last_activity_time_to_db
            return unless sorcery_config.register_last_activity_time
            return unless logged_in?

            current_user.set_last_activity_at(Time.current)
          end
        end
      end
    end
  end
end
