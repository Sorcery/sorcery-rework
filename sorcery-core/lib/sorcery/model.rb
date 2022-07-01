# frozen_string_literal: true

require 'securerandom'

module Sorcery
  # FIXME: Can any of this be extracted or simplified?

  ##
  # Extends the user model(s) with Sorcery's methods.
  #
  module Model
    ##
    # Extends the calling class with Sorcery's model methods, as well as
    # providing an interface to customize the configuration on a per class basis
    # using a block.
    #
    # For example:
    #
    #   class User < ApplicationRecord
    #     authenticates_with_sorcery! do |config|
    #       config.encryption_algorithm = :argon2
    #     end
    #   end
    #--
    # TODO: Extract / simplify method if possible.
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    #++
    #
    def authenticates_with_sorcery!
      @sorcery_config = ::Sorcery::Config.instance.dup
      @sorcery_config.configure!

      # Allow overwriting config for each class
      yield(@sorcery_config) if block_given?

      extend ClassMethods
      include InstanceMethods

      include_plugins!
      load_plugin_settings!
      define_sorcery_orm_adapter!
      define_base_fields!
      init_orm_hooks!
      init_hashing_provider!

      if @sorcery_config.model_subclasses_inherit_config
        @sorcery_config.after_config << :add_config_inheritance
      end
      @sorcery_config.after_config.each { |c| send(c) }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    ##
    # This will be overwritten with Sorcery::OrmAdapters::ActiveRecord in
    # railtie.rb
    #
    def sorcery_orm_adapter
      ::Sorcery::OrmAdapters::Base.from(self)
    end

    def include_plugins!
      class_eval do
        @sorcery_config.plugins.each do |plugin|
          include model_plugin_const(plugin)
        end
      end
    end

    # FIXME: Performance of this method is abyssmal, optimization needed.
    # rubocop:disable Metrics/MethodLength
    def load_plugin_settings!
      @sorcery_config.plugins.each do |plugin|
        # TODO: Find a better name than "klass"
        @sorcery_config.plugin_settings[plugin].each do |klass, plugin_settings|
          next unless klass == :model

          plugin_settings.each do |key, value|
            # TODO: This method of assigning keys can probably be improved.
            config_method = "#{key}=".to_sym
            if @sorcery_config.respond_to?(config_method)
              @sorcery_config.__send__(config_method, value)
            else
              raise ArgumentError,
                "Invalid plugin setting provided! `#{key}` is not a valid " \
                "option for the Sorcery `#{plugin}` plugin."
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    # TODO: Extract plugin const detection into an object and depend on it.
    def model_plugin_const(plugin_symbol)
      ::Sorcery::Plugins.plugin_const(plugin_symbol).const_get(:Model)
    end

    ##
    # Provides an abstraction so that we don't overwrite sorcery_orm_adapter if
    # it's already defined (e.g. by railtie.rb)
    #
    def define_sorcery_orm_adapter!
      # Including the super methods on this check is intentional.
      return if instance_methods.include?(:sorcery_orm_adapter)

      define_method(:sorcery_orm_adapter) do
        @sorcery_orm_adapter ||= ::Sorcery::OrmAdapters::Base.new(self)
      end
    end

    ##
    # Necessary for ORMs like MongoID
    #
    #--
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    #++
    #
    def define_base_fields!
      class_eval do
        sorcery_config.username_attr_names.each do |username|
          sorcery_orm_adapter.define_field(
            username,
            String,
            length: 255
          )
        end
        # FIXME: LineLength here is a little tricky to solve.
        # rubocop:disable Layout/LineLength
        unless sorcery_config.username_attr_names.include?(sorcery_config.email_attr_name)
          sorcery_orm_adapter.define_field(
            sorcery_config.email_attr_name,
            String,
            length: 255
          )
        end
        # rubocop:enable Layout/LineLength
        sorcery_orm_adapter.define_field(
          sorcery_config.password_digest_attr_name,
          String,
          length: 255
        )
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    ##
    # Add virtual password accessors and ORM callbacks.
    #
    #--
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    #++
    #
    def init_orm_hooks!
      sorcery_orm_adapter.define_callback(
        :before, :validation, :digest_password,
        if: proc { |record|
          record.send(sorcery_config.password_attr_name).present?
        }
      )

      sorcery_orm_adapter.define_callback(
        :after, :save, :clear_virtual_password,
        if: proc { |record|
          record.send(sorcery_config.password_attr_name).present?
        }
      )

      return unless sorcery_config.password_attr_name.present?

      attr_accessor sorcery_config.password_attr_name
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def init_hashing_provider!
      @sorcery_hashing_provider = @sorcery_config.hashing_provider
    end

    # rubocop:disable Metrics/ModuleLength
    module ClassMethods # :nodoc:
      def sorcery_config
        @sorcery_config
      end

      def sorcery_hashing_provider
        @sorcery_hashing_provider
      end

      def sorcery_session_class
        @sorcery_session_class ||= sorcery_config.session_class.to_s.constantize
      rescue NameError
        raise Sorcery::Errors::ConfigError,
          'You have incorrectly defined session_class or have forgotten to ' \
          'define it in your Sorcery initializer file ' \
          '(config.session_class = \'UserSession\').'
      end

      ##
      # The default authentication method.
      # Takes a username and password,
      # Finds the user by the username and compares the user's password to the
      # one supplied to the method.
      #
      # Returns the user if successful, nil otherwise.
      #
      #--
      # FIXME: This method is so complex that four different cops bark about it.
      #        Extract as much as possible into smaller discrete chunks?
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      #++
      #
      def authenticate(username, password, &block)
        unless username.present? && password.present?
          raise ArgumentError,
            'Username and password are required to authenticate via Sorcery!'
        end

        unless username.is_a?(String) && password.is_a?(String)
          raise ArgumentError,
            'Username and password must be strings to authenticate via Sorcery!'
        end

        if username.blank?
          return authentication_response(
            status: :invalid_login,
            &block
          )
        end

        if sorcery_config.downcase_username_before_authenticating
          username.downcase!
        end

        # TODO: Support multiple emails/usernames via association (and array
        #       attribute?).
        user = sorcery_orm_adapter.find_by_credentials(username)

        unless user
          return authentication_response(status: :invalid_login, &block)
        end

        inactive_for_authentication = (
          user.respond_to?(:active_for_authentication?) &&
          !user.active_for_authentication?
        )

        if inactive_for_authentication
          return authentication_response(user: user, status: :inactive, &block)
        end

        sorcery_config.before_authenticate.each do |callback|
          success, reason = user.send(callback)

          unless success
            return authentication_response(user: user, status: reason, &block)
          end
        end

        unless user.valid_password?(password)
          return authentication_response(
            user:   user,
            status: :invalid_password,
            &block
          )
        end

        authentication_response(
          user:         user,
          status:       :success,
          return_value: user,
          &block
        )
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity

      def load_from_token(token, token_attr_name, exp_attr_name = nil, &block)
        return token_response(failure: :invalid_token, &block) if token.blank?

        user = sorcery_orm_adapter.find_by_token(token_attr_name, token)

        return token_response(failure: :user_not_found, &block) unless user

        unless sorcery_token_expired?(user, exp_attr_name)
          return token_response(user: user, failure: :token_expired, &block)
        end

        token_response(user: user, return_value: user, &block)
      end

      ##
      # Create a password hash using the current hashing_provider.
      #
      def digest(password)
        raise NotImplementedError if @sorcery_hashing_provider.nil?

        @sorcery_hashing_provider.digest(password)
      end

      ##
      # Random secure token, used for temporary tokens.
      #
      #--
      # Having this be loaded via `include` using `self.` is 1:1 with previous
      # functionality, but doesn't make much sense. Investigate if this can be
      # moved to `ClassMethods` and the `self.` dropped.
      #
      # Edit: Updated to be ClassMethods due to authenticate failing from
      # missing method, double check that there are no other repercussions, then
      # remove this note.
      #++
      #
      def generate_random_token
        SecureRandom.urlsafe_base64(
          sorcery_config.token_randomness
        ).tr('lIO0', 'sxyz')
      end

      protected

      def authentication_response(options = {})
        yield(options[:user], options[:status]) if block_given?

        options[:return_value]
      end

      # TODO: Identical to authentication_response, DRY?
      def token_response(options = {})
        yield(options[:user], options[:status]) if block_given?

        options[:return_value]
      end

      # TODO: Reduce complexity
      # TODO: Shouldn't the hashing_provider just read from the config
      #       directly? Or alternatively, these values get set as a part of the
      #       config process instead.
      # rubocop:disable Layout/LineLength
      # def set_encryption_attributes
      #   if @sorcery_config.hashing_provider.respond_to?(:stretches) && @sorcery_config.stretches
      #     @sorcery_config.hashing_provider.stretches = @sorcery_config.stretches
      #   end
      #   return unless @sorcery_config.hashing_provider.respond_to?(:pepper) && @sorcery_config.pepper

      #   @sorcery_config.hashing_provider.pepper = @sorcery_config.pepper
      # end
      # rubocop:enable Layout/LineLength

      # rubocop:disable Metrics/MethodLength
      def add_config_inheritance
        class_eval do
          def self.inherited(subclass)
            subclass.class_eval do
              class << self
                attr_accessor :sorcery_config
              end
            end
            subclass.sorcery_config = sorcery_config
            super
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def sorcery_token_expired?(user, token_expiration_date_attr)
        return true unless token_expiration_date_attr

        expires_at = user.send(token_expiration_date_attr)

        !expires_at || (Time.now.in_time_zone < expires_at)
      end
    end
    # rubocop:enable Metrics/ModuleLength

    module InstanceMethods # :nodoc:
      def sorcery_config
        self.class.sorcery_config
      end

      def sorcery_hashing_provider
        self.class.sorcery_hashing_provider
      end

      def sorcery_session_class
        self.class.sorcery_session_class
      end

      def create_sorcery_session!
        sorcery_session = sorcery_session_class.new
        association_symbol = "#{model_name.singular}=".to_sym
        sorcery_session.send(association_symbol, self)
        sorcery_session.save!
        sorcery_session
      end

      ##
      # Identifies whether a user is regular, i.e. we hold their credentials in
      # the db, or that they are external and their credentials are saved
      # elsewhere. (e.g. twitter/facebook etc.)
      #
      def external?
        # If the user class doesn't support passwords, then external? should
        # always be true.
        return true unless sorcery_config.password_digest_attr_name.present?

        # Otherwise, check if the specific user instance has a password saved in
        # the database.
        send(sorcery_config.password_digest_attr_name).nil?
      end

      ##
      # Calls the configured crypto provider to compare the supplied
      # password with the hashed one.
      #
      def valid_password?(password)
        # If the user class doesn't support passwords, then all passwords are
        # by extension invalid.
        return false unless sorcery_config.password_digest_attr_name.present?

        raise NotImplementedError if sorcery_hashing_provider.nil?

        digest = send(sorcery_config.password_digest_attr_name)

        # TODO: Add specs to verify that this works when switching between
        #       different crypto settings.

        sorcery_hashing_provider.digest_matches?(digest, password)
      end

      protected

      ##
      # Uses the current crypto provider to generate a password hash (aka
      # digest) then assign it to the digest attribute.
      #
      def digest_password
        send(
          :"#{sorcery_config.password_digest_attr_name}=",
          self.class.digest(send(sorcery_config.password_attr_name))
        )
      end

      ##
      # Clears the virtual password and password_confirmation attributes after
      # saving.
      #
      #--
      # TODO: Why do we do this?
      #++
      #
      def clear_virtual_password
        send(:"#{sorcery_config.password_attr_name}=", nil)

        # FIXME: This solution to LineLength looks bad, but the other options
        #        look even worse. Maybe consider config = sorcery_config again?
        return unless respond_to?(
          :"#{sorcery_config.password_attr_name}_confirmation="
        )

        send(:"#{sorcery_config.password_attr_name}_confirmation=", nil)
      end

      ##
      # Calls the requested email method on the configured mailer. Both
      # email_method_name and mailer refer to classes defined in the
      # Sorcery.configure block.
      #
      def generic_send_email(email_method_name, mailer)
        mail = sorcery_config.
               send(mailer).
               send(sorcery_config.send(email_method_name), self)
        return unless mail.respond_to?(sorcery_config.email_delivery_method)

        mail.send(sorcery_config.email_delivery_method)
      end
    end
  end
end
