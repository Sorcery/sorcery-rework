# frozen_string_literal: true

module Sorcery
  ##
  # Extends ActiveRecord with Sorcery's methods.
  #
  module Model
    def authenticates_with_sorcery!
      # FIXME: This must be a config instance to allow per class modifications
      @sorcery_config = ::Sorcery::Config.instance.dup
      @sorcery_config.configure!

      # Allow overwriting config for each class
      yield(@sorcery_config) if block_given?

      extend ClassMethods
      include InstanceMethods

      include_plugins!
    end

    private

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

    module ClassMethods # :nodoc:
      def sorcery_config
        @sorcery_config
      end

      def authenticate(*_credentials, &_block)
        'This returns values! Wow!'
      end
    end

    module InstanceMethods # :nodoc:
      def sorcery_config
        self.class.sorcery_config
      end
    end
  end
end
