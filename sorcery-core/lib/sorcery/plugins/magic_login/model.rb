# frozen_string_literal: true

module Sorcery
  module Plugins
    module MagicLogin
      module Model # :nodoc:
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Layout/LineLength
        def self.included(base)
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)

          base.sorcery_config.add_plugin_defaults(
            magic_login_token_attribute_name:            :magic_login_token,
            magic_login_token_expires_at_attribute_name: :magic_login_token_expires_at,
            magic_login_email_sent_at_attribute_name:    :magic_login_email_sent_at,
            magic_login_mailer_class:                    nil,
            magic_login_mailer_disabled:                 true,
            magic_login_email_method_name:               :magic_login_email,
            magic_login_expiration_period:               15 * 60,
            magic_login_time_between_emails:             5 * 60
          )

          base.sorcery_config.after_config << :validate_mailer_defined
          base.sorcery_config.after_config << :define_magic_login_fields
        end
        # rubocop:enable Layout/LineLength
        # rubocop:enable Metrics/MethodLength

        module ClassMethods # :nodoc:
          ##
          # Find user by token, also checks for expiration.
          # Returns the user if token found and is valid.
          #
          def load_from_magic_login_token(token, &block)
            load_from_token(
              token,
              sorcery_config.magic_login_token_attribute_name,
              sorcery_config.magic_login_token_expires_at_attribute_name,
              &block
            )
          end

          protected

          ##
          # This submodule requires the developer to define their own mailer
          # class to be used by it when magic_login_mailer_disabled is false.
          #
          def validate_mailer_defined
            return unless
              sorcery_config.magic_login_mailer_class.nil? &&
              sorcery_config.magic_login_mailer_disabled == false

            raise Sorcery::Errors::ConfigError,
              'To use the magic_login submodule, you must define a mailer '\
              '(config.magic_login_mailer_class = YourMailerClass).'
          end

          # rubocop:disable Metrics/MethodLength
          def define_magic_login_fields
            sorcery_adapter.define_field(
              sorcery_config.magic_login_token_attribute_name,
              String
            )
            sorcery_adapter.define_field(
              sorcery_config.magic_login_token_expires_at_attribute_name,
              Time
            )
            sorcery_adapter.define_field(
              sorcery_config.magic_login_email_sent_at_attribute_name,
              Time
            )
          end
          # rubocop:enable Metrics/MethodLength
        end

        module InstanceMethods # :nodoc:
          # generates a reset code with expiration
          # rubocop:disable Layout/LineLength
          def generate_magic_login_token!
            config = sorcery_config
            attributes = {
              config.magic_login_token_attribute_name         => self.class.generate_random_token,
              config.magic_login_email_sent_at_attribute_name => Time.now.in_time_zone
            }
            if config.magic_login_expiration_period
              attributes[config.magic_login_token_expires_at_attribute_name] =
                Time.now.in_time_zone + config.magic_login_expiration_period
            end

            sorcery_adapter.update_attributes(attributes)
          end
          # rubocop:enable Layout/LineLength

          # generates a magic login code with expiration and sends an email to
          # the user.
          # rubocop:disable Layout/LineLength
          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/MethodLength
          def deliver_magic_login_instructions!
            mail = false
            config = sorcery_config
            # hammering protection
            return false if !config.magic_login_time_between_emails.nil? &&
                            send(config.magic_login_email_sent_at_attribute_name) &&
                            send(config.magic_login_email_sent_at_attribute_name) > config.magic_login_time_between_emails.seconds.ago

            self.class.sorcery_orm_adapter.transaction do
              generate_magic_login_token!
              unless config.magic_login_mailer_disabled
                send_magic_login_email!
                mail = true
              end
            end
            mail
          end
          # rubocop:enable Layout/LineLength
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          # Clears the token.
          def clear_magic_login_token!
            config = sorcery_config
            sorcery_adapter.update_attributes(
              config.magic_login_token_attribute_name            => nil,
              config.magic_login_token_expires_at_attribute_name => nil
            )
          end

          protected

          def send_magic_login_email!
            generic_send_email(:magic_login_email_method_name,
              :magic_login_mailer_class)
          end
        end
      end
    end
  end
end
