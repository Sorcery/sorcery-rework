# frozen_string_literal: true

module Sorcery
  module Plugins
    module UserActivation
      module Model # :nodoc:
        # rubocop:disable Layout/LineLength
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def self.included(base)
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)

          base.sorcery_config.add_plugin_defaults(
            activation_state_attribute_name:            :activation_state,
            activation_token_attribute_name:            :activation_token,
            activation_token_expires_at_attribute_name: :activation_token_expires_at,
            activation_token_expiration_period:         nil,
            user_activation_mailer:                     nil,
            activation_mailer_disabled:                 false,
            activation_needed_email_method_name:        :activation_needed_email,
            activation_success_email_method_name:       :activation_success_email,
            prevent_non_active_users_to_login:          true
          )

          base.class_eval do
            # don't setup activation if no password supplied - this user is created automatically
            sorcery_orm_adapter.define_callback(
              :before, :create,
              :setup_activation,
              if: proc { |user| user.send(sorcery_config.password_attribute_name).present? }
            )
            # don't send activation needed email if no crypted password created - this user is external (OAuth etc.)
            sorcery_orm_adapter.define_callback(
              :after, :commit,
              :send_activation_needed_email!,
              on: :create,
              if: :send_activation_needed_email?
            )
          end

          base.sorcery_config.after_config << :validate_mailer_defined
          base.sorcery_config.after_config << :define_user_activation_fields
          base.sorcery_config.before_authenticate << :prevent_non_active_login
        end
        # rubocop:enable Layout/LineLength
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        ##
        # TODO
        #
        module ClassMethods
          # Find user by token, also checks for expiration.
          # Returns the user if token found and is valid.
          def load_from_activation_token(token, &block)
            load_from_token(
              token,
              @sorcery_config.activation_token_attribute_name,
              @sorcery_config.activation_token_expires_at_attribute_name,
              &block
            )
          end

          protected

          # This submodule requires the developer to define his own mailer class
          # to be used by it when activation_mailer_disabled is false
          def validate_mailer_defined
            return unless
              sorcery_config.user_activation_mailer.nil? &&
              sorcery_config.activation_mailer_disabled == false

            raise Sorcery::Errors::ConfigError,
              'To use user_activation submodule, you must define a mailer '\
              '(config.user_activation_mailer = YourMailerClass).'
          end

          # rubocop:disable Metrics/MethodLength
          def define_user_activation_fields
            class_eval do
              sorcery_adapter.define_field(
                sorcery_config.activation_state_attribute_name,
                String
              )
              sorcery_adapter.define_field(
                sorcery_config.activation_token_attribute_name,
                String
              )
              sorcery_adapter.define_field(
                sorcery_config.activation_token_expires_at_attribute_name,
                Time
              )
            end
          end
          # rubocop:enable Metrics/MethodLength
        end

        module InstanceMethods # :nodoc:
          # rubocop:disable Metrics/MethodLength
          def setup_activation
            config = sorcery_config
            generated_activation_token = self.class.generate_random_token
            send(
              :"#{config.activation_token_attribute_name}=",
              generated_activation_token
            )
            send(
              :"#{config.activation_state_attribute_name}=",
              'pending'
            )
            return unless config.activation_token_expiration_period

            send(
              :"#{config.activation_token_expires_at_attribute_name}=",
              Time.now.in_time_zone + config.activation_token_expiration_period
            )
          end
          # rubocop:enable Metrics/MethodLength

          # clears activation code, sets the user as 'active' and optionaly
          # sends a success email.
          def activate!
            config = sorcery_config
            send(:"#{config.activation_token_attribute_name}=", nil)
            send(:"#{config.activation_state_attribute_name}=", 'active')
            send_activation_success_email! if send_activation_success_email?
            sorcery_adapter.save(validate: false, raise_on_failure: true)
          end

          attr_accessor :skip_activation_needed_email,
            :skip_activation_success_email

          protected

          # called automatically after user initial creation.
          def send_activation_needed_email!
            generic_send_email(
              :activation_needed_email_method_name,
              :user_activation_mailer
            )
          end

          def send_activation_success_email!
            generic_send_email(
              :activation_success_email_method_name,
              :user_activation_mailer
            )
          end

          def send_activation_success_email?
            !external? &&
              !(
                sorcery_config.activation_success_email_method_name.nil? ||
                sorcery_config.activation_mailer_disabled == true
              ) &&
              !skip_activation_success_email
          end

          def send_activation_needed_email?
            !external? &&
              !(
                sorcery_config.activation_needed_email_method_name.nil? ||
                sorcery_config.activation_mailer_disabled == true
              ) &&
              !skip_activation_needed_email
          end

          def prevent_non_active_login
            config = sorcery_config
            return true unless config.prevent_non_active_users_to_login
            if send(config.activation_state_attribute_name) == 'active'
              return true
            end

            [false, :inactive]
          end
        end
      end
    end
  end
end
