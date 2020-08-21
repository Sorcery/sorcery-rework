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
      plugins:                                 [],
      ################
      ## Attributes ##
      ################
      crypted_password_attribute_name:         :crypted_password,
      email_attribute_name:                    :email,
      password_attribute_name:                 :password,
      username_attribute_names:                [:email],
      ###############
      ## Passwords ##
      ###############
      encryption_algorithm:                    :bcrypt,
      # TODO: Remove encryption_key if encrypt method is removed.
      encryption_key:                          nil,
      encryption_provider:                     'CryptoProviders::BCrypt',
      custom_encryption_provider:              nil,
      pepper:                                  '',
      salt_join_token:                         '',
      salt_attribute_name:                     :salt,
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
      ###########
      ## Other ##
      ###########
      after_config:                            [],
      before_authenticate:                     [],
      email_delivery_method:                   :deliver_now,
      login_session_key:                       :user_id,
      login_sources:                           Set.new,
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
