# frozen_string_literal: true

##
#
module Sorcery
  # Helper method to shorten `Rails.application.config.sorcery.configure` to
  # just `Sorcery.configure`
  def self.configure(&block)
    Config.configure(&block)
  end

  ##
  # Example usage in a Rails application:
  #
  #   # ./config/initializers/sorcery.rb
  #
  #   Sorcery.configure do |config|
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
  #--
  # rubocop:disable Metrics/ClassLength
  #++
  #
  class Config
    # Defaults for Sorcery Core (plugins will add their own default values)
    DEFAULTS = {
      # TODO: Prevent editing plugins list directly (force calling load_plugin)
      plugins:                                 [],
      plugin_settings:                         {},
      ################
      ## Attributes ##
      ################
      # TODO: Rename `crypted_password` -> `password_digest`?
      crypted_password_attribute_name:         :crypted_password,
      email_attribute_name:                    :email,
      password_attribute_name:                 :password,
      username_attribute_names:                [:email],
      ###############
      ## Passwords ##
      ###############
      encryption_algorithm:                    :bcrypt,
      custom_encryption_provider:              nil,
      # TODO: Implement migrating/rotating passwords to new algorithms when
      #       logging in. Will a require method to determine if user should use
      #       old algo (which will be defined by the application, NOT Sorcery).
      previous_encryption_provider:            nil,
      pepper:                                  '',
      stretches:                               nil,
      ###########
      ## Model ##
      ###########
      model_subclasses_inherit_config:         false,
      ################
      ## Controller ##
      ################
      downcase_username_before_authenticating: false,
      not_authenticated_action:                :not_authenticated,
      session_key:                             :user_id,
      login_sources:                           Set.new,
      before_logout:                           Set.new,
      after_failed_login:                      Set.new,
      after_login:                             Set.new,
      after_logout:                            Set.new,
      after_remember_me:                       Set.new,
      ###########
      ## Other ##
      ###########
      after_config:                            [],
      before_authenticate:                     [],
      email_delivery_method:                   :deliver_now,
      save_return_to_url:                      true,
      token_randomness:                        15,
      user_class:                              :nil
    }.freeze

    private_constant :DEFAULTS

    ##
    # What is `class << self`, and why do we use it?
    #
    # For the most part, it's a shortcut to mark all methods inside the block as
    # class methods. For example, these two code examples should be functionally
    # equivalent:
    #
    #   class Config
    #     def self.instance
    #       @instance ||= new(DEFAULTS)
    #     end
    #   end
    #
    #   class Config
    #     class << self
    #       def instance
    #         @instance ||= new(DEFAULTS)
    #       end
    #     end
    #   end
    #
    # There are two primary benefits to using `class << self` in these
    # situations:
    #
    # 1. It makes the code a little easier to read, due to not littering our def
    #    calls with `self.` and grouping all class methods together in a block.
    # 2. It also affects metaprogramming, making it slightly easier to tell
    #    what's going on. For example, see the loop that delegates the Config
    #    class methods to instance methods.
    #
    #   [:some, :symbols, :here].each do |method_name|
    #     class_eval <<-RUBY, __FILE__, __LINE__ + 1
    #       def #{method_name}(&block)
    #         return instance.#{method_name}(&block) if block_given?
    #         instance.#{method_name}
    #       end
    #     RUBY
    #   end
    #
    # Whereas if we didn't use `class << self`:
    #
    #   [:some, :symbols, :here].each do |method_name|
    #     class_eval <<-RUBY, __FILE__, __LINE__ + 1
    #       def self.#{method_name}(&block)
    #         return instance.#{method_name}(&block) if block_given?
    #         instance.#{method_name}
    #       end
    #     RUBY
    #   end
    #
    # There is a little bit of witchcraft associated with
    # `class << instance_var`, in that it will create class methods that only
    # are extended to that specific instance of the class.
    #
    # Example per: https://stackoverflow.com/a/38041660
    #
    #   class Config
    #   end
    #
    #   config1 = Config.new
    #   config2 = Config.new
    #
    #   class << config1
    #     def say_hello
    #       puts "Hello!"
    #     end
    #   end
    #
    #   config1.say_hello # Output: Hello!
    #   config2.say_hello # Output: NoMethodError: undefined method 'say_hello'
    #
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
          # NOTE: This uses <<- instead of do/end due to performance gains
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{default_key}           # def self.session_key
              instance.#{default_key}         #   instance.session_key
            end                               # end

            def self.#{default_key}=(value)   # def self.session_key=(value)
              instance.#{default_key} = value #   instance.session_key = value
            end                               # end
          RUBY
        end

        @instance = instance.merge(defaults)
      end
      # rubocop:enable Metrics/MethodLength

      def load_plugin(plugin, settings = {})
        instance.load_plugin(plugin, settings)
      end

      def unload_plugin(plugin)
        instance.unload_plugin(plugin)
      end

      # Delegate class methods to instance methods
      [:reset!, :user_config, :configure, :configure!].each do |method_name|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method_name}(&block)                               # def reset!(&block)
            return instance.#{method_name}(&block) if block_given? #   return instance.reset!(&block) if block_given?
            instance.#{method_name}                                #   instance.reset!
          end                                                      # end
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
      block ? @user_config = block : @user_config
    end

    # FIXME: This probably has unintended consequences, such as persisting
    #        custom settings as global defaults for subsequent calls to config.
    #        This should instead only add the defaults to the particular calling
    #        instance.
    def add_plugin_defaults(defaults)
      self.class.add_defaults(defaults)
      load_plugin_defaults!(defaults)
    end

    # FIXME: The entire settings situation feels a bit jank, consider
    #        refactoring once a better understanding of the flow is attained.
    def load_plugin_defaults!(defaults)
      defaults.each do |k, v|
        next if instance_variable_defined?("@#{k}")

        instance_variable_set("@#{k}", v)
      end
    end

    def configure(&block)
      @configure_block = block
    end

    def configure!
      @configure_block&.call(self)
      nil
    end

    def load_plugin(plugin, settings = {})
      unless plugin.is_a?(Symbol)
        raise ArgumentError, 'Plugin must be a symbol!'
      end
      unless settings.is_a?(Hash)
        raise ArgumentError, 'Settings must be a hash!'
      end

      plugins << plugin unless plugins.include?(plugin)
      plugin_settings[plugin] = settings
    end

    def unload_plugin(plugin)
      unless plugin.is_a?(Symbol)
        raise ArgumentError, 'Plugin must be a symbol!'
      end

      plugins.reject! { |loaded_plugin| loaded_plugin == plugin }
    end

    def merge(other)
      combined_defaults = attributes.merge(other)
      self.class.new(combined_defaults)
    end

    def dup
      self.class.new(attributes)
    end

    def encryption_provider
      case @encryption_algorithm.to_sym
      when :none   then nil
      when :argon2 then ::Sorcery::CryptoProviders::Argon2
      when :bcrypt then ::Sorcery::CryptoProviders::BCrypt
      when :custom then @custom_encryption_provider
      else
        raise ArgumentError,
          "Encryption algorithm supplied, #{@encryption_algorithm}, is invalid"
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
  # rubocop:enable Metrics/ClassLength
end
