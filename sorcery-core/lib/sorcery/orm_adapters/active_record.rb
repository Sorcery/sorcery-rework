# frozen_string_literal: true

module Sorcery
  module OrmAdapters
    ##
    # This adapter is automatically extended to ActiveRecord::Base by
    # Sorcery::Railtie
    #--
    # TODO: Document methods and clean as needed
    #++
    #
    class ActiveRecord < Base
      def update_attributes(attrs)
        attrs.each do |name, value|
          @model.send(:"#{name}=", value)
        end
        primary_key = @model.class.primary_key
        updated_count = @model.class.where(
          "#{primary_key}": @model.send(:"#{primary_key}")
        ).update_all(attrs)
        updated_count == 1
      end

      def save(options = {})
        save_method = options.delete(:raise_on_failure) ? :save! : :save
        @model.send(save_method, **options)
      end

      def increment(field)
        @model.increment!(field)
      end

      def find_authentication_by_oauth_credentials(relation_name, provider, uid)
        # TODO: This may not work as intended, double check that @model is
        #       always a model that calls `authenticates_with_sorcery!`
        # TODO: Also, check if it would make more sense to just call
        #       `@model.sorcery_config` all the time instead of assigning it to
        #       `@user_config`
        @user_config ||= @model.sorcery_config
        conditions = {
          @user_config.provider_uid_attr_name => uid,
          @user_config.provider_attr_name     => provider
        }

        @model.public_send(relation_name).where(conditions).first
      end

      class << self
        def define_field(name, type, options = {})
          # AR fields are defined through migrations, only validator here
        end

        def define_callback(time, event, method_name, options = {})
          @klass.send "#{time}_#{event}", method_name, **options.slice(:if, :on)
        end

        def find_by_oauth_credentials(provider, uid)
          @user_config ||= @model.sorcery_config
          conditions = {
            @user_config.provider_uid_attr_name => uid,
            @user_config.provider_attr_name     => provider
          }

          @klass.where(conditions).first
        end

        def find_by_remember_me_token(token)
          @klass.where(
            @klass.sorcery_config.remember_me_token_attr_name => token
          ).first
        end

        ##
        #--
        # TODO: Technically overlaps with find_by_username now. Axe one or the
        #       other?
        # TODO: Cleanup and simplify method.
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        #++
        #
        def find_by_credentials(username)
          relation = nil

          @klass.sorcery_config.username_attr_names.each do |attribute|
            condition =
              if @klass.sorcery_config.downcase_username_before_authenticating
                @klass.arel_table[attribute].lower.eq(
                  @klass.arel_table.lower(username)
                )
              else
                @klass.arel_table[attribute].eq(username)
              end

            relation =
              if relation.nil?
                condition
              else
                relation.or(condition)
              end
          end

          @klass.where(relation).first
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def find_by_token(token_attr_name, token)
          condition = @klass.arel_table[token_attr_name].eq(token)

          @klass.where(condition).first
        end

        def find_by_activation_token(token)
          @klass.where(
            @klass.sorcery_config.activation_token_attr_name => token
          ).first
        end

        def find_by_id(id)
          @klass.find_by_id(id)
        end

        def find_by_username(username)
          @klass.sorcery_config.username_attr_names.each do |attribute|
            if @klass.sorcery_config.downcase_username_before_authenticating
              username = username.downcase
            end

            result = @klass.where(attribute => username).first
            return result if result
          end
        end

        def find_by_email(email)
          @klass.where(
            @klass.sorcery_config.email_attr_name => email
          ).first
        end

        def transaction(&blk)
          @klass.tap(&blk)
        end
      end
    end
  end
end
