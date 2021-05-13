# frozen_string_literal: true

module Sorcery
  module Plugins
    module RememberMe
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
            after_config: [:define_remember_me_fields]
          }
        end

        # rubocop:disable Layout/LineLength
        def self.plugin_defaults
          {
            remember_me_token_attr_name:            :remember_me_token,
            remember_me_token_expires_at_attr_name: :remember_me_token_expires_at,
            remember_me_token_persist_globally:          false,
            remember_me_for:                             7 * 60 * 60 * 24
          }
        end
        # rubocop:enable Layout/LineLength

        module ClassMethods # :nodoc:
          protected

          def define_remember_me_fields
            sorcery_orm_adapter.define_field(
              sorcery_config.remember_me_token_attr_name,
              String
            )
            sorcery_orm_adapter.define_field(
              sorcery_config.remember_me_token_expires_at_attr_name,
              Time
            )
          end
        end

        ##
        # TODO
        #
        module InstanceMethods
          ##
          # You shouldn't really use this one yourself - it's called by the
          # controller's 'remember_me!' method.
          #--
          # rubocop:disable Metrics/MethodLength
          #++
          #
          def remember_me!
            update_options = {
              sorcery_config.remember_me_token_expires_at_attr_name => (
                Time.current + sorcery_config.remember_me_for
              )
            }

            # FIXME: LineLength here causes horrible readability.
            unless sorcery_config.remember_me_token_persist_globally &&
                   remember_me_token?

              update_options[sorcery_config.remember_me_token_attr_name] =
                self.class.generate_random_token
            end

            sorcery_orm_adapter.update_attributes(update_options)
          end
          # rubocop:enable Metrics/MethodLength

          def remember_me_token?
            send(sorcery_config.remember_me_token_attr_name).present?
          end

          ##
          # You shouldn't really use this one yourself - it's called by the
          # controller's 'forget_me!' method.
          #
          # We only clear the token value if
          # remember_me_token_persist_globally == false.
          #
          def forget_me!
            return if sorcery_config.remember_me_token_persist_globally

            force_forget_me!
          end

          ##
          # You shouldn't really use this one yourself - it's called by the
          # controller's 'force_forget_me!' method.
          #
          def force_forget_me!
            sorcery_orm_adapter.update_attributes(
              sorcery_config.remember_me_token_attr_name            => nil,
              sorcery_config.remember_me_token_expires_at_attr_name => nil
            )
          end
        end
      end
    end
  end
end
