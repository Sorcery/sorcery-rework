# frozen_string_literal: true

module Sorcery
  module Plugins
    module BruteForceProtection
      ##
      # This module helps protect user accounts by locking them down after too
      # many failed attempts to login were detected.
      # This is the controller part of the submodule which takes care of
      # updating the failed logins and resetting them.
      # See Sorcery::Plugins::BruteForceProtection::Model for configuration
      # options.
      #
      module Controller
        extend Sorcery::Plugin

        def self.plugin_callbacks
          {
            after_login:        [:reset_failed_logins_count!],
            after_failed_login: [:update_failed_logins_count!]
          }
        end

        # def self.plugin_dependencies
        #   [:password_login]
        # end

        module InstanceMethods # :nodoc:
          protected

          #################
          ## after_login ##
          #################

          # Resets the failed logins counter.
          # Runs as a hook after a successful login.
          def reset_failed_logins_count!(user, _username, _password, _options)
            user.sorcery_orm_adapter.update_attribute(
              user_class.sorcery_config.failed_logins_count_attr_name,
              0
            )
          end

          ########################
          ## after_failed_login ##
          ########################

          # Increments the failed logins counter on every failed login.
          # Runs as a hook after a failed login.
          def update_failed_logins_count!(username, _password, _options)
            user = user_class.sorcery_orm_adapter.find_by_credentials(
              username
            )
            user&.register_failed_login!
          end
        end
      end
    end
  end
end
