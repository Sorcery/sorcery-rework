# frozen_string_literal: true

module Sorcery
  module Plugins
    module SessionTimeout
      module Controller # :nodoc:
        extend Sorcery::Plugin

        def self.add_callbacks(base)
          base.prepend_before_action :validate_session
        end

        def self.plugin_callbacks
          {
            after_login:       [:register_login_time_after_login],
            after_remember_me: [:register_login_time_after_remember_me]
          }
        end

        def self.plugin_defaults
          {
            session_timeout:                                    3600, # 1.hour
            session_timeout_from_last_action:                   false,
            session_timeout_invalidate_active_sessions_enabled: false
          }
        end

        module InstanceMethods # :nodoc:
          def invalidate_active_sessions!
            return unless sorcery_config.
                          session_timeout_invalidate_active_sessions_enabled
            return unless current_user.present?

            # FIXME: Why isn't this in the model? Who did this? Ugh.
            current_user.send(:invalidate_sessions_before=, Time.current)
            current_user.save
          end

          protected

          ##
          # Registers last login to be used as the timeout starting point.
          # Runs as a hook after a successful login.
          #
          def register_login_time_after_login(_user, _username, _password,
            _options)
            register_login_time
          end

          def register_login_time_after_remember_me(_user)
            register_login_time
          end

          ##
          # Registers last login to be used as the timeout starting point.
          #
          def register_login_time
            session[:login_time]       = Time.current
            session[:last_action_time] = Time.current
          end

          # Checks if session timeout was reached and expires the current
          # session if so.
          # To be used as a before_action, before require_login
          # rubocop:disable Layout/LineLength
          def validate_session
            session_to_use = sorcery_config.session_timeout_from_last_action ? session[:last_action_time] : session[:login_time]
            if (session_to_use && sorcery_session_expired?(session_to_use.to_time)) || sorcery_session_invalidated?
              logout(skip_callbacks: true)
            else
              session[:last_action_time] = Time.current
            end
          end
          # rubocop:enable Layout/LineLength

          def sorcery_session_expired?(time)
            Time.current - time > sorcery_config.session_timeout
          end

          # Use login time if present, otherwise use last action time.
          # rubocop:disable Layout/LineLength
          def sorcery_session_invalidated?
            unless sorcery_config.session_timeout_invalidate_active_sessions_enabled
              return false
            end
            unless current_user.present? && current_user.try(:invalidate_sessions_before).present?
              return false
            end

            time = session[:login_time] || session[:last_action_time] || Time.current
            time < current_user.invalidate_sessions_before
          end
          # rubocop:enable Layout/LineLength
        end
      end
    end
  end
end
