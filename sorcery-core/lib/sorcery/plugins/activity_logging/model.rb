# frozen_string_literal: true

module Sorcery
  module Plugins
    module ActivityLogging
      ##
      # For additional configuration options, see:
      # Sorcery::Plugins::ActivityLogging::Controller
      #
      module Model
        extend Sorcery::Plugin

        def self.plugin_callbacks
          {
            after_config: [:define_activity_logging_fields]
          }
        end

        def self.plugin_defaults
          {
            last_login_at_attr_name:         :last_login_at,
            last_logout_at_attr_name:        :last_logout_at,
            last_activity_at_attr_name:      :last_activity_at,
            last_login_from_ip_address_name: :last_login_from_ip_address,
            activity_timeout:                10 * 60
          }
        end

        ##
        # TODO
        #
        module ClassMethods
          protected

          # rubocop:disable Metrics/MethodLength
          def define_activity_logging_fields
            sorcery_orm_adapter.define_field(
              sorcery_config.last_login_at_attr_name,
              Time
            )
            sorcery_orm_adapter.define_field(
              sorcery_config.last_logout_at_attr_name,
              Time
            )
            sorcery_orm_adapter.define_field(
              sorcery_config.last_activity_at_attr_name,
              Time
            )
            sorcery_orm_adapter.define_field(
              sorcery_config.last_login_from_ip_address_name,
              String
            )
          end
          # rubocop:enable Metrics/MethodLength
        end

        ##
        # Note that these methods exist on instances of the Model and not in the
        # controller.
        #
        module InstanceMethods
          # TODO: Rename methods or fix design pattern
          # rubocop:disable Naming/AccessorMethodName
          def set_last_login_at(time)
            sorcery_orm_adapter.update_attribute(
              sorcery_config.last_login_at_attr_name,
              time
            )
          end

          def set_last_logout_at(time)
            sorcery_orm_adapter.update_attribute(
              sorcery_config.last_logout_at_attr_name,
              time
            )
          end

          def set_last_activity_at(time)
            sorcery_orm_adapter.update_attribute(
              sorcery_config.last_activity_at_attr_name,
              time
            )
          end

          def set_last_ip_address(ip_address)
            sorcery_orm_adapter.update_attribute(
              sorcery_config.last_login_from_ip_address_name,
              ip_address
            )
          end
          # rubocop:enable Naming/AccessorMethodName

          ##
          # Returns true if a user has been active recently and has not logged
          # out since the last action taken.
          #
          def online?
            logged_in? && recently_active?
          end

          def recently_active?
            return false if send(sorcery_config.last_activity_at_attr_name).nil?

            (
              send(sorcery_config.last_activity_at_attr_name) >
              sorcery_config.activity_timeout.seconds.ago
            )
          end

          ##
          # Shows if a user is logged in, but does not consider if they have
          # been active recently. To see if a user is logged in and active, use
          # `online?`
          #
          def logged_in?
            last_login = send(sorcery_config.last_login_at_attr_name)
            return false if last_login.nil?

            last_logout = send(sorcery_config.last_logout_at_attr_name)
            return true if last_login.present? && last_logout.nil?

            last_login > last_logout
          end

          def logged_out?
            !logged_in?
          end
        end
      end
    end
  end
end
