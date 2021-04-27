# frozen_string_literal: true

module Sorcery
  module Plugins
    module BruteForceProtection
      ##
      # This module helps protect user accounts by locking them down after too
      # many failed attemps to login were detected.
      # This is the model part of the submodule which provides configuration
      # options and methods for locking and unlocking the user.
      #
      module Model
        extend Sorcery::Plugin

        def self.plugin_callbacks
          {
            before_authenticate: [:prevent_locked_user_login],
            after_config:        [:define_brute_force_protection_fields]
          }
        end

        def self.plugin_defaults
          {
            failed_logins_count_attribute_name:     :failed_logins_count,
            lock_expires_at_attribute_name:         :lock_expires_at,
            consecutive_login_retries_amount_limit: 50,
            login_lock_time_period:                 60 * 60,
            unlock_token_attribute_name:            :unlock_token,
            unlock_token_email_method_name:         :send_unlock_token_email,
            unlock_token_mailer_disabled:           false,
            unlock_token_mailer:                    nil
          }
        end

        ##
        # TODO
        #
        module ClassMethods
          # This doesn't check to see if the account is still locked
          def load_from_unlock_token(token, &block)
            return if token.blank?

            load_from_token(
              token,
              sorcery_config.unlock_token_attribute_name,
              &block
            )
          end

          protected

          # rubocop:disable Metrics/MethodLength
          def define_brute_force_protection_fields
            sorcery_orm_adapter.define_field(
              sorcery_config.failed_logins_count_attribute_name,
              Integer,
              default: 0
            )
            sorcery_orm_adapter.define_field(
              sorcery_config.lock_expires_at_attribute_name,
              Time
            )
            sorcery_orm_adapter.define_field(
              sorcery_config.unlock_token_attribute_name,
              String
            )
          end
          # rubocop:enable Metrics/MethodLength
        end

        ##
        # TODO
        #
        module InstanceMethods
          # Called by the controller to increment the failed logins counter.
          # Calls 'login_lock!' if login retries limit was reached.
          def register_failed_login!
            config = sorcery_config
            return unless login_unlocked?

            sorcery_orm_adapter.
              increment(config.failed_logins_count_attribute_name)

            failed_count = send(config.failed_logins_count_attribute_name)
            failed_limit = config.consecutive_login_retries_amount_limit
            return unless failed_count >= failed_limit

            login_lock!
          end

          # /!\
          # Moved out of protected for use like activate! in controller
          # /!\
          def login_unlock!
            config = sorcery_config
            attributes = {
              config.lock_expires_at_attribute_name     => nil,
              config.failed_logins_count_attribute_name => 0,
              config.unlock_token_attribute_name        => nil
            }
            sorcery_orm_adapter.update_attributes(attributes)
          end

          def login_locked?
            !login_unlocked?
          end

          protected

          ##
          #--
          # TODO: Fix LineLength (shorter attribute names?)
          # rubocop:disable Layout/LineLength
          #++
          #
          def login_lock!
            config = sorcery_config
            attributes = {
              config.lock_expires_at_attribute_name => Time.current + config.login_lock_time_period,
              config.unlock_token_attribute_name    => self.class.generate_random_token
            }
            sorcery_orm_adapter.update_attributes(attributes)

            if config.unlock_token_mailer_disabled || config.unlock_token_mailer.nil?
              return
            end

            send_unlock_token_email!
          end
          # rubocop:enable Layout/LineLength

          def login_unlocked?
            config = sorcery_config
            send(config.lock_expires_at_attribute_name).nil?
          end

          def send_unlock_token_email!
            return if sorcery_config.unlock_token_email_method_name.nil?

            generic_send_email(
              :unlock_token_email_method_name,
              :unlock_token_mailer
            )
          end

          # Prevents a locked user from logging in, and unlocks users that
          # expired their lock time.
          # Runs as a hook before authenticate.
          def prevent_locked_user_login
            config = sorcery_config
            should_unlock =
              !login_unlocked? &&
              config.login_lock_time_period != 0 &&
              send(config.lock_expires_at_attribute_name) <= Time.current

            login_unlock! if should_unlock

            return false, :locked unless login_unlocked?

            true
          end
        end
      end
    end
  end
end
