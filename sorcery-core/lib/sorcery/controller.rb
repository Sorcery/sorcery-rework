# frozen_string_literal: true

module Sorcery
  module Controller # :nodoc:
    def authenticates_with_sorcery!
      include InstanceMethods

      include_plugins!

      ::Sorcery::Config.update!
      ::Sorcery::Config.configure!
    end

    private

    # TODO: This is essentially 1:1 with the Model version of this method. DRY?
    def include_plugins!
      class_eval do
        ::Sorcery::Config.plugins.each do |plugin|
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

    module InstanceMethods # :nodoc:
      def current_user
        @current_user ||= nil
      end

      def current_user=(user)
        @current_user = user
      end
    end
  end
end
