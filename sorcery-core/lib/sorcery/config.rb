# frozen_string_literal: true

module Sorcery
  ##
  # Example usage in a Rails application:
  #
  #   # ./config/initializers/sorcery.rb
  #
  #   Rails.application.config.sorcery.configure do |config|
  #     config.some_variable = true
  #
  #     config.load_plugin(
  #       [...]
  #     )
  #
  #     [etc...]
  #   end
  #
  # Special thanks to @sinsoku for the basis of this new config methodology.
  #
  class Config
    # Defaults for Sorcery Core (plugins will add their own default values)
    DEFAULTS = {
      # TODO: Prevent editing plugins list directly (force calling load_plugin)
      plugins:                  [],
      not_authenticated_action: :not_authenticated,
      user_class:               :nil,
      login_session_key:        :user_id,
      login_sources:            Set.new,
      save_return_to_url:       true
    }.freeze

    private_constant :DEFAULTS

    # TODO: No seriously, how do eigenclasses work? What is this witchcraft?
    class << self
      def instance
        @instance ||= new(DEFAULTS)
      end

      # TODO: Unused, remove?
      # def init!
      #   @instance = new(DEFAULTS)
      # end

      ##
      # Used by plugins to extend the defaults with new values.
      #--
      # TODO: Extract defaults.each_key block into new method?
      # rubocop:disable Metrics/MethodLength
      #++
      #
      def add_defaults(defaults)
        attr_accessor(*defaults.keys)

        # This block defines class getters/setters for each new default, and
        # delegates it to the singleton instance.
        defaults.each_key do |default_key|
          # TODO: Determine why this uses <<- instead of do/end.
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{default_key}
              instance.#{default_key}
            end

            def self.#{default_key}=(value)
              instance.#{default_key} = value
            end
          RUBY
        end

        @instance = instance.merge(defaults)
      end
      # rubocop:enable Metrics/MethodLength

      # Delegate class methods to instance methods
      [:reset!, :user_config, :configure, :configure!].each do |method_name|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method_name}(&block)
            return instance.#{method_name}(&block) if block_given?
            instance.#{method_name}
          end
        RUBY
      end
    end

    def initialize(defaults)
      # TODO: Ask @sinsoku why we dup both the base hash as well as the values.
      #       Normally it would make sense that the values would already be dups
      @defaults = defaults.dup.transform_values do |value|
        value.is_a?(Class) ? value : value.dup
      end
      reset_to_defaults!
    end

    def reset_to_defaults!
      @defaults.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end

    def user_config(&block)
      block_given? ? @user_config = block : @user_config
    end

    # TODO: Unused, remove?
    # def update!
    #   @defaults.each do |k, v|
    #     next if instance_variable_defined?(k)

    #     instance_variable_set(k, v)
    #   end
    # end

    def configure(&block)
      @configure_block = block
    end

    def configure!
      @configure_block&.call(self)
      nil
    end

    def merge(other)
      combined_defaults = attributes.merge(other)
      self.class.new(combined_defaults)
    end

    def dup
      self.class.new(attributes)
    end

    ##
    # Provides an abstraction to allow setting your session key as a proc.
    #--
    # TODO: Are there any consequences to this abstraction layer / allowing
    # procs? Would it be preferable to remove it?
    #++
    #
    def session_key
      if login_session_key.is_a?(Proc)
        login_session_key.call(self)
      else
        login_session_key
      end
    end

    # TODO: Is there a better way to access all instance variables?
    private

    def attributes
      keys = @defaults.keys + [:user_config, :configure_block]
      keys.map { |key| [key, instance_variable_get("@#{key}")] }.to_h
    end

    add_defaults(DEFAULTS)
  end
end
