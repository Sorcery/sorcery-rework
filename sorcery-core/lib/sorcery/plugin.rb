# frozen_string_literal: true

module Sorcery
  ##
  # Provides the generic interface for defining a Sorcery plugin
  #
  module Plugin
    def included(base)
      add_sorcery_plugin(base)
    end

    def add_sorcery_plugin(base)
      add_methods(base)
      add_config(base)
      add_callbacks(base)
    end

    # FIXME: self::Module might be too clever for its own good (aka confusing)
    def add_methods(base)
      base.extend(self::ClassMethods) if defined?(self::ClassMethods)
      return unless defined?(self::InstanceMethods)

      base.send(:include, self::InstanceMethods)
    end

    def add_config(base)
      base.sorcery_config.add_plugin_defaults(plugin_defaults)
      base.sorcery_config.add_callbacks(plugin_callbacks)
    end

    ##
    # To be overwritten by plugins as needed
    #
    def add_callbacks(base); end

    def plugin_callbacks
      {}
    end

    def plugin_defaults
      {}
    end
  end
end
