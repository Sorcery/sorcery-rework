# frozen_string_literal: true

require 'securerandom'

module Sorcery
  ##
  # Extends ActiveRecord with Sorcery's methods.
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
      define_base_fields!
      init_orm_hooks!

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
      @sorcery_orm_adapter ||= ::Sorcery::OrmAdapters::Base.new(self)
    end

    def include_plugins!
      class_eval do
        @sorcery_config.plugins.each do |plugin|
          include ::Sorcery::Plugins.
            const_get(plugin_const_string(plugin)).
            const_get('Model')
        end
      end
    end

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
        sorcery_config.username_attribute_names.each do |username|
          sorcery_orm_adapter.define_field(
            username,
            String,
            length: 255
          )
        end
        # FIXME: LineLength here is a little tricky to solve.
        # rubocop:disable Layout/LineLength
        unless sorcery_config.username_attribute_names.include?(sorcery_config.email_attribute_name)
          sorcery_orm_adapter.define_field(
            sorcery_config.email_attribute_name,
            String,
            length: 255
          )
        end
        # rubocop:enable Layout/LineLength
        sorcery_orm_adapter.define_field(
          sorcery_config.crypted_password_attribute_name,
          String,
          length: 255
        )
        sorcery_orm_adapter.define_field(
          sorcery_config.salt_attribute_name,
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
        :before, :validation, :encrypt_password,
        if: proc { |record|
          record.send(sorcery_config.password_attribute_name).present?
        }
      )

      sorcery_orm_adapter.define_callback(
        :after, :save, :clear_virtual_password,
        if: proc { |record|
          record.send(sorcery_config.password_attribute_name).present?
        }
      )

      return unless sorcery_config.password_attribute_name.present?

      attr_accessor sorcery_config.password_attribute_name
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    ##
    # TODO
    #
    #--
    # rubocop:disable Metrics/ModuleLength
    #++
    #
    module ClassMethods
      def sorcery_config
        @sorcery_config
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
      def authenticate(*credentials, &block)
        unless credentials.is_a?(Array)
          raise ArgumentError, 'Credentials must be an Array!'
        end

        if credentials.size < 2
          # FIXME: I don't like the styling here, update rubocop config to fix.
          raise ArgumentError,
                'Username and password are required to authenticate via '\
                'Sorcery!'
        end

        # TODO: Does this return false for a particular reason? If not, it
        #       should be nil instead.
        if credentials[0].blank?
          return authentication_response(
            return_value: false,
            failure:      :invalid_login,
            &block
          )
        end

        if @sorcery_config.downcase_username_before_authenticating
          credentials[0].downcase!
        end

        user = sorcery_orm_adapter.find_by_credentials(credentials)

        unless user
          return authentication_response(failure: :invalid_login, &block)
        end

        set_encryption_attributes

        inactive_for_authentication = (
          user.respond_to?(:active_for_authentication?) &&
          !user.active_for_authentication?
        )

        if inactive_for_authentication
          return authentication_response(user: user, failure: :inactive, &block)
        end

        @sorcery_config.before_authenticate.each do |callback|
          success, reason = user.send(callback)

          unless success
            return authentication_response(user: user, failure: reason, &block)
          end
        end

        unless user.valid_password?(credentials[1])
          return authentication_response(
            user:    user,
            failure: :invalid_password,
            &block
          )
        end

        authentication_response(user: user, return_value: user, &block)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity

      def load_from_token(token, token_attr_name, exp_attr_name = nil, &block)
        return token_response(failure: :invalid_token, &block) if token.blank?

        user = sorcery_orm_adapter.find_by_token(token_attr_name, token)

        return token_response(failure: :user_not_found, &block) unless user

        unless check_expiration_date(user, exp_attr_name)
          return token_response(user: user, failure: :token_expired, &block)
        end

        token_response(user: user, return_value: user, &block)
      end

      ##
      # Encrypt tokens using current encryption_provider.
      #
      #--
      # TODO: Should this be removed entirely? (only support hashing passwords)
      #++
      #
      def encrypt(*tokens)
        return tokens.first if @sorcery_config.encryption_provider.nil?

        set_encryption_attributes

        CryptoProviders::AES256.key = @sorcery_config.encryption_key
        @sorcery_config.encryption_provider.encrypt(*tokens)
      end

      protected

      def authentication_response(options = {})
        yield(options[:user], options[:failure]) if block_given?

        options[:return_value]
      end

      # TODO: Identical to authentication_response, DRY?
      def token_response(options = {})
        yield(options[:user], options[:failure]) if block_given?

        options[:return_value]
      end

      # TODO: Reduce complexity
      # TODO: Shouldn't the encryption_provider just read from the config
      #       directly? Or alternatively, these values get set as a part of the
      #       config process instead.
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Layout/LineLength
      def set_encryption_attributes
        if @sorcery_config.encryption_provider.respond_to?(:stretches) && @sorcery_config.stretches
          @sorcery_config.encryption_provider.stretches = @sorcery_config.stretches
        end
        if @sorcery_config.encryption_provider.respond_to?(:join_token) && @sorcery_config.salt_join_token
          @sorcery_config.encryption_provider.join_token = @sorcery_config.salt_join_token
        end
        return unless @sorcery_config.encryption_provider.respond_to?(:pepper) && @sorcery_config.pepper

        @sorcery_config.encryption_provider.pepper = @sorcery_config.pepper
      end
      # rubocop:enable Metrics/AbcSize
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

      def check_expiration_date(user, token_expiration_date_attr)
        return true unless token_expiration_date_attr

        expires_at = user.send(token_expiration_date_attr)

        !expires_at || (Time.now.in_time_zone < expires_at)
      end
    end
    # rubocop:enable Metrics/ModuleLength

    ##
    # TODO
    #
    module InstanceMethods
      def sorcery_config
        self.class.sorcery_config
      end

      ##
      # Random secure token, used for salt and temporary tokens.
      #
      #--
      # Having this be loaded via `include` using `self.` is 1:1 with previous
      # functionality, but doesn't make much sense. Investigate if this can be
      # moved to `ClassMethods` and the `self.` dropped.
      #++
      #
      def self.generate_random_token
        SecureRandom.urlsafe_base64(
          @sorcery_config.token_randomness
        ).tr('lIO0', 'sxyz')
      end

      ##
      # Identifies whether a user is regular, i.e. we hold their credentials in
      # the db, or that they are external and their credentials are saved
      # elsewhere. (e.g. twitter/facebook etc.)
      #
      def external?
        # If the user class doesn't support passwords, then external? should
        # always be true.
        unless sorcery_config.crypted_password_attribute_name.present?
          return true
        end

        # Otherwise, check if the specific user instance has a password saved in
        # the database.
        send(sorcery_config.crypted_password_attribute_name).nil?
      end

      ##
      # Calls the configured crypto provider to compare the supplied
      # password with the encrypted one.
      #
      #--
      # TODO: Reduce complexity
      # rubocop:disable Metrics/AbcSize
      #++
      #
      def valid_password?(pass)
        # If the user class doesn't support passwords, then all passwords are
        # by extension invalid.
        unless sorcery_config.crypted_password_attribute_name.present?
          return false
        end

        crypted = send(sorcery_config.crypted_password_attribute_name)

        return crypted == pass if sorcery_config.encryption_provider.nil?

        salt =
          if sorcery_config.salt_attribute_name.present?
            send(sorcery_config.salt_attribute_name)
          end

        sorcery_config.encryption_provider.matches?(crypted, pass, salt)
      end
      # rubocop:enable Metrics/AbcSize

      protected

      ##
      # Generates a new salt, then takes the password, salt, and crypto provider
      # to generate the crypted password.
      #
      #--
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      #++
      #
      def encrypt_password
        new_salt =
          if sorcery_config.salt_attribute_name.present?
            self.class.generate_random_token
          end

        send(:"#{sorcery_config.salt_attribute_name}=", new_salt) if new_salt

        send(
          :"#{sorcery_config.crypted_password_attribute_name}=",
          self.class.encrypt(
            send(sorcery_config.password_attribute_name), new_salt
          )
        )
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      ##
      # Clears the virtual password and password_confirmation attributes after
      # saving.
      #
      #--
      # TODO: Why do we do this?
      #++
      #
      def clear_virtual_password
        send(:"#{sorcery_config.password_attribute_name}=", nil)

        # FIXME: This solution to LineLength looks bad, but the other options
        #        look even worse. Maybe consider config = sorcery_config again?
        return unless respond_to?(
          :"#{sorcery_config.password_attribute_name}_confirmation="
        )

        send(:"#{sorcery_config.password_attribute_name}_confirmation=", nil)
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
