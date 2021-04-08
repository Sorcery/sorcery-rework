# frozen_string_literal: true

module Sorcery
  module Plugins
    module ResetPassword
      module Model # :nodoc:
        # rubocop:disable Layout/LineLength
        # rubocop:disable Metrics/MethodLength
        def self.included(base)
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)

          base.sorcery_config.add_plugin_defaults(
            reset_password_token_attribute_name:             :reset_password_token,
            reset_password_token_expires_at_attribute_name:  :reset_password_token_expires_at,
            reset_password_page_access_count_attribute_name: :access_count_to_reset_password_page,
            reset_password_email_sent_at_attribute_name:     :reset_password_email_sent_at,
            reset_password_mailer:                           nil,
            reset_password_mailer_disabled:                  false,
            reset_password_email_method_name:                :reset_password_email,
            reset_password_expiration_period:                nil,
            reset_password_time_between_emails:              5 * 60
          )

          base.sorcery_config.after_config << :validate_mailer_defined
          base.sorcery_config.after_config << :define_reset_password_fields
        end
        # rubocop:enable Layout/LineLength
        # rubocop:enable Metrics/MethodLength

        ##
        # TODO
        #
        module ClassMethods
          # Find user by token, also checks for expiration.
          # Returns the user if token found and is valid.
          def load_from_reset_password_token(token, &block)
            load_from_token(
              token,
              @sorcery_config.reset_password_token_attribute_name,
              @sorcery_config.reset_password_token_expires_at_attribute_name,
              &block
            )
          end

          protected

          # This submodule requires the developer to define his own mailer class
          # to be used by it when reset_password_mailer_disabled is false
          def validate_mailer_defined
            return unless
              sorcery_config.reset_password_mailer.nil? &&
              sorcery_config.reset_password_mailer_disabled == false

            raise Sorcery::Errors::ConfigError,
              'To use reset_password submodule, you must define a mailer '\
              '(config.reset_password_mailer = YourMailerClass).'
          end

          # rubocop:disable Metrics/MethodLength
          def define_reset_password_fields
            sorcery_adapter.define_field(
              sorcery_config.reset_password_token_attribute_name,
              String
            )
            sorcery_adapter.define_field(
              sorcery_config.reset_password_token_expires_at_attribute_name,
              Time
            )
            sorcery_adapter.define_field(
              sorcery_config.reset_password_email_sent_at_attribute_name,
              Time
            )
          end
          # rubocop:enable Metrics/MethodLength
        end

        ##
        # TODO
        #
        module InstanceMethods
          # Generates a reset code with expiration
          # rubocop:disable Layout/LineLength
          def generate_reset_password_token!
            config = sorcery_config
            attributes = {
              config.reset_password_token_attribute_name         => self.class.generate_random_token,
              config.reset_password_email_sent_at_attribute_name => Time.now.in_time_zone
            }
            if config.reset_password_expiration_period
              attributes[config.reset_password_token_expires_at_attribute_name] =
                Time.now.in_time_zone + config.reset_password_expiration_period
            end

            sorcery_adapter.update_attributes(attributes)
          end
          # rubocop:enable Layout/LineLength

          # Generates a reset code with expiration and sends an email to the
          # user.
          # rubocop:disable Layout/LineLength
          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/MethodLength
          def deliver_reset_password_instructions!
            mail = false
            config = sorcery_config
            # hammering protection
            if config.reset_password_time_between_emails.present? && send(config.reset_password_email_sent_at_attribute_name) && send(config.reset_password_email_sent_at_attribute_name) > config.reset_password_time_between_emails.seconds.ago.utc
              return false
            end

            self.class.sorcery_adapter.transaction do
              generate_reset_password_token!
              unless config.reset_password_mailer_disabled
                mail = send_reset_password_email!
              end
            end
            mail
          end
          # rubocop:enable Layout/LineLength
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          # Increment access_count_to_reset_password_page attribute.
          # For example, access_count_to_reset_password_page attribute is over
          # 1, which means the user doesn't have a right to access.
          def increment_password_reset_page_access_counter
            sorcery_adapter.increment(
              sorcery_config.reset_password_page_access_count_attribute_name
            )
          end

          # Reset access_count_to_reset_password_page attribute into 0.
          # This is expected to be used after sending an instruction email.
          # rubocop:disable Layout/LineLength
          def reset_password_reset_page_access_counter
            send(
              :"#{sorcery_config.reset_password_page_access_count_attribute_name}=", 0
            )
            sorcery_adapter.save
          end
          # rubocop:enable Layout/LineLength

          # Clears token and tries to update the new password for the user.
          def change_password(new_password, raise_on_failure: false)
            clear_reset_password_token
            send(:"#{sorcery_config.password_attribute_name}=", new_password)
            sorcery_adapter.save raise_on_failure: raise_on_failure
          end

          def change_password!(new_password)
            change_password(new_password, raise_on_failure: true)
          end

          protected

          def send_reset_password_email!
            generic_send_email(:reset_password_email_method_name,
              :reset_password_mailer)
          end

          # Clears the token.
          def clear_reset_password_token
            config = sorcery_config
            send(:"#{config.reset_password_token_attribute_name}=", nil)
            return unless config.reset_password_expiration_period

            send(
              :"#{config.reset_password_token_expires_at_attribute_name}=",
              nil
            )
          end
        end
      end
    end
  end
end
