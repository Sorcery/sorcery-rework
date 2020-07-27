# frozen_string_literal: true

module Sorcery
  module Config # :nodoc:
    # TODO: What on earth is an Eigenclass, and how do you use it?
    class << self
      attr_accessor :plugins

      def init!
        @defaults = {
          :@plugins => []
        }
        reset_to_defaults!
      end

      def reset_to_defaults!
        @defaults.each do |k, v|
          instance_variable_set(k, v)
        end
      end

      def update!
        @defaults.each do |k, v|
          next if instance_variable_defined?(k)

          instance_variable_set(k, v)
        end
      end

      def user_config(&block)
        block_given? ? @user_config = block : @user_config
      end

      def configure(&block)
        @configure_block = block
      end

      def configure!
        @configure_block&.call(self)
      end
    end

    init!
  end
end
