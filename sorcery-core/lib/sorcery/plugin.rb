# frozen_string_literal: true

module Sorcery
  ##
  # Provides the generic interface for defining a Sorcery plugin
  #
  module Plugin
    def included(base)
      add_sorcery_plugin(base)
    end

    def plugin_name
      to_s.split('::').third
    end

    def add_sorcery_plugin(base)
      check_plugin_dependencies(base)
      add_methods(base)
      add_config(base)
      add_callbacks(base)
    end

    ##
    # Extends the model or controller with the class and instance methods
    # defined in the plugin submodules.
    #
    #    module MyPlugin
    #      module Model
    #        extend Sorcery::Plugin
    #
    #        module InstanceMethods
    #          def my_instance_method
    #            puts 'Does stuff!'
    #          end
    #        end
    #      end
    #    end
    #
    #    class User < ApplicationRecord
    #      authenticates_with_sorcery! do |config|
    #        config.load_plugin(:my_plugin)
    #      end
    #    end
    #
    #    User.new.my_instance_method
    #    => "Does stuff!"
    #
    #
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

    def check_plugin_dependencies(base)
      missing_plugins = plugin_dependencies.reject do |plugin|
        base.sorcery_config.plugins.include?(plugin)
      end

      return unless missing_plugins.any?

      raise Sorcery::Errors::PluginDependencyError,
        "The Sorcery #{plugin_name} plugin depends on the following other "\
        "plugins: #{missing_plugins.join(', ')}"
    end

    def plugin_callbacks
      {}
    end

    def plugin_defaults
      {}
    end

    def plugin_dependencies
      []
    end
  end
end
