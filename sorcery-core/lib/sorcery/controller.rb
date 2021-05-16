# frozen_string_literal: true

module Sorcery
  ##
  # Extends ActionController with Sorcery's methods.
  #
  module Controller
    def authenticates_with_sorcery!
      @sorcery_config = ::Sorcery::Config.instance.dup
      @sorcery_config.configure!

      # Allow overwriting config for each class
      yield(@sorcery_config) if block_given?

      extend ClassMethods
      include InstanceMethods

      include_plugins!
      load_plugin_settings!
      add_config_inheritance!

      @sorcery_config.after_config.each { |c| send(c) }
    end

    private

    # TODO: This is essentially 1:1 with the Model version of this method. DRY?
    def include_plugins!
      class_eval do
        @sorcery_config.plugins.each do |plugin|
          include controller_plugin_const(plugin)
        end
      end
      # TODO: This should also take config settings from `load_plugin` calls,
      #       and apply them now that they've been added by the plugin
      #       `self.included` calls.
    end

    # FIXME: Performance of this method is abyssmal, optimization needed.
    # rubocop:disable Metrics/MethodLength
    def load_plugin_settings!
      @sorcery_config.plugins.each do |plugin|
        # TODO: Find a better name than "klass"
        @sorcery_config.plugin_settings[plugin].each do |klass, plugin_settings|
          next unless klass == :controller

          plugin_settings.each do |key, value|
            # TODO: This method of assigning keys can probably be improved.
            config_method = "#{key}=".to_sym
            if @sorcery_config.respond_to?(config_method)
              @sorcery_config.__send__(config_method, value)
            else
              raise Sorcery::Errors::ConfigError,
                "Invalid plugin setting provided! `#{key}` is not a valid "\
                "option for the Sorcery `#{plugin}` plugin."
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    # TODO: Extract plugin const detection into an object and depend on it.
    def controller_plugin_const(plugin_symbol)
      ::Sorcery::Plugins.plugin_const(plugin_symbol).const_get('Controller')
    end

    ##
    # TODO
    #
    module ClassMethods
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

    ##
    #--
    # TODO: Extract something?
    # rubocop:disable Metrics/ModuleLength
    #++
    #
    module InstanceMethods
      ##
      # To be used as before_action.
      # Will trigger auto-login attempts via the call to logged_in?
      # If all attempts to auto-login fail, the failure callback will be called.
      #--
      # rubocop:disable Metrics/AbcSize
      #++
      #
      def require_login
        return if logged_in?

        save_return_to_url = (
          sorcery_config.save_return_to_url &&
          request.get? &&
          !request.xhr? &&
          !request.format.json?
        )

        session[:return_to_url] = request.url if save_return_to_url

        send(sorcery_config.not_authenticated_action)
      end
      # rubocop:enable Metrics/AbcSize

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

      ##
      # Takes credentials and returns a user on successful authentication.
      #
      # If successful, calls `after_login` hook.
      # If unsuccessful, calls `failed_login` hook.
      #
      #--
      # TODO: Audit login method for security as well as logic.
      # rubocop:disable Metrics/MethodLength
      #++
      #
      # def login(username, password, options = {})
      #   @current_user = nil
      #
      #   user_class.authenticate(username, password) do |user, failure_reason|
      #     if failure_reason
      #       after_failed_login!(username, password, options)
      #
      #       yield(user, failure_reason) if block_given?
      #
      #       # No user on failed login, return nil.
      #       return nil
      #     end
      #
      #     reset_sorcery_session(keep_values: true)
      #
      #     # credentials[2] is the remember_me value, but is currently unused.
      #     auto_login(user, options)
      #     after_login!(user, username, password, options)
      #
      #     # Return current user
      #     block_given? ? yield(current_user, nil) : current_user
      #   end
      # end
      # rubocop:enable Metrics/MethodLength

      def login(username, password, options = {})
        @current_user = nil

        user_class.authenticate(username, password) do |user, status|
          case status
          when :success
            login = login_as_user(user)
            after_login!(user, username, password, options)
          when :verification_required
            raise NotImplementedError
          else
            # No user on failed login, return nil.
            login = nil
            after_failed_login!(username, password, options)
          end

          yield(user, status) if block_given?

          return login
        end
      end

      ##
      # Protect from session fixation attacks
      #
      def reset_sorcery_session(keep_values: false)
        if keep_values
          # TODO: `to_hash` is functionally different from `to_h`, double check
          # that this usage is intended. (Typically you should use to_h)
          # https://stackoverflow.com/a/26610268
          old_session = session.dup.to_hash
          reset_session
          old_session.each_pair do |key, value|
            session[key.to_sym] = value
          end
          form_authenticity_token
        else
          reset_session
        end
      end

      ##
      # Resets the session and runs hooks before and after.
      #
      def logout
        return unless logged_in?

        user = current_user
        before_logout!
        @current_user = nil
        reset_sorcery_session
        after_logout!(user)
      end

      ##
      # Used in conjunction with `require_login` to take a user back to a page
      # they requested while logged out after logging in.
      #
      def redirect_back_or_to(default_url, flash_hash = {})
        redirect_to(session[:return_to_url] || default_url, flash: flash_hash)
        session[:return_to_url] = nil
      end

      ##
      # The default action for denying non-authenticated users.
      #
      # You can override this method in your controllers, or provide a different
      # method in the configuration.
      #
      def not_authenticated
        redirect_to root_path
      end

      ##
      # Login to a user instance.
      #
      # @param [<User-Model>] user the user instance.
      # @return - do not depend on the return value.
      #
      def login_as_user(user)
        session_store_method =
          "create_sorcery_#{sorcery_config.session_store}".to_sym

        unless respond_to?(session_store_method)
          raise Sorcery::Errors::ConfigError,
            "Unknown session store: #{sorcery_config.session_store}\n"\
            "Double check that you included the necessary plugins."
        end

        send(session_store_method, user)
      end

      def create_sorcery_local_session(user)
        reset_sorcery_session(keep_values: true)
        session[sorcery_config.session_key] = user.id.to_s
        @current_user = user
      end

      # Add deprecation warning
      def auto_login(user, _options = {})
        login_as_user(user)
      end

      ##
      # Overwrite Rails' handle unverified request
      #
      def handle_unverified_request
        sorcery_config.before_unverified_request.each do |callback|
          send(callback)
        end
        @current_user = nil
        super # call the default behaviour which resets the session
      end

      def sorcery_config
        self.class.sorcery_config
      end

      protected

      def login_from_session
        return nil unless session[sorcery_config.session_key].present?

        @current_user = user_class.sorcery_orm_adapter.find_by_id(
          session[sorcery_config.session_key]
        )
      end

      ##
      # Checks all `login_sources` listed in the config and uses the first one
      # that finds a user. If none of the sources can find a user, this method
      # returns nil instead.
      #
      # Important to note, `find` does not return the result of the block, but
      # instead the element found. In this case, it would return the symbol of
      # the login source method rather than the return value of that method.
      # That's why we must use the result placeholder variable.
      #
      def login_from_other_sources
        result = nil
        # Takes the first entry that doesn't return false
        sorcery_config.login_sources.find do |source|
          result = send(source)
        end
        return result if result

        nil
      end

      def user_class
        @user_class ||= sorcery_config.user_class.to_s.constantize
      rescue NameError
        raise ArgumentError,
          'You have incorrectly defined user_class or have forgotten to '\
          'define it in your Sorcery initializer file '\
          '(config.user_class = \'User\').'
      end

      #######################
      ## Callbacks / Hooks ##
      #######################

      ##
      # See Sorcery::Controller::InstanceMethods#login
      #
      def after_login!(user, username = '', password = '', options = {})
        sorcery_config.after_login.each do |callback|
          send(callback, user, username, password, options)
        end
      end

      ##
      # See Sorcery::Controller::InstanceMethods#login
      #
      def after_failed_login!(username = '', password = '', options = {})
        sorcery_config.after_failed_login.each do |callback|
          send(callback, username, password, options)
        end
      end

      ##
      # See Sorcery::Controller::InstanceMethods#logout
      #
      def before_logout!
        sorcery_config.before_logout.each do |callback|
          send(callback)
        end
      end

      ##
      # See Sorcery::Controller::InstanceMethods#logout
      #
      def after_logout!(user)
        sorcery_config.after_logout.each do |callback|
          send(callback, user)
        end
      end

      # TODO: Unused, remove or move into remember me plugin controller file.
      def after_remember_me!(user)
        sorcery_config.after_remember_me.each do |callback|
          send(callback, user)
        end
      end
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
