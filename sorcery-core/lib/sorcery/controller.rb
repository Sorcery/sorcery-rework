# frozen_string_literal: true

module Sorcery
  ##
  # Extends ActionController with Sorcery's methods.
  #
  module Controller
    def authenticates_with_sorcery!
      # FIXME: This must be a config instance to allow per class modifications
      @sorcery_config = ::Sorcery::Config.instance.dup
      @sorcery_config.configure!

      # Allow overwriting config for each class
      yield(@sorcery_config) if block_given?

      extend ClassMethods
      include InstanceMethods

      include_plugins!
      add_config_inheritance!
    end

    private

    # TODO: This is essentially 1:1 with the Model version of this method. DRY?
    def include_plugins!
      class_eval do
        @sorcery_config.plugins.each do |plugin|
          include ::Sorcery::Plugins.
            const_get(plugin_const_string(plugin)).
            const_get('Controller')
        end
      end
    end

    # TODO: This is essentially 1:1 with the Model version of this method. DRY?
    def plugin_const_string(plugin_symbol)
      case plugin_symbol
      when :mfa
        'MFA'
      when :oauth
        'OAuth'
      else
        plugin_symbol.to_s.split('_').map(&:capitalize).join
      end
    end

    module ClassMethods # :nodoc:
      def sorcery_config
        @sorcery_config
      end

      protected

      # TODO: Is there any way to simplify this method?
      # rubocop:disable Metrics/MethodLength
      def add_config_inheritance!
        class_eval do
          def self.inherited(subclass)
            subclass.class_eval do
              class << self
                attr_accessor :sorcery_config
              end
            end
            # Pass parent config to subclass
            subclass.sorcery_config = sorcery_config
            super
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end

    module InstanceMethods # :nodoc:
      def require_login
        return if logged_in?

        send(sorcery_config.not_authenticated_action)
      end

      # TODO: Would `current_user.present?` be preferable here?
      def logged_in?
        !!current_user
      end

      def current_user
        return @current_user if defined?(@current_user)
        @current_user = login_from_session || login_from_other_sources || nil
      end

      def current_user=(user)
        @current_user = user
      end

      protected

      def sorcery_config
        self.class.sorcery_config
      end

      def login_from_session
        return unless session[sorcery_config.session_key].present?
        @current_user = user_class.find_by_id(
          session[sorcery_config.session_key]
        )
      end

      def login_from_other_sources
        result = nil
        # Takes the first entry that doesn't return false
        sorcery_config.login_sources.find do |source|
          result = send(source)
        end
        # FIXME: Shouldn't this be `result || nil`?
        result || false
      end

      def user_class
        @user_class ||= sorcery_config.user_class.to_s.constantize
      rescue NameError
        raise ArgumentError,
          'You have incorrectly defined user_class or have forgotten to '\
          'define it in your Sorcery initializer file '\
          '(config.user_class = \'User\').'
      end
    end
  end
end
