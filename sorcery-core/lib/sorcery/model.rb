# frozen_string_literal: true

module Sorcery
  module Model # :nodoc:
    def authenticates_with_sorcery!
      @sorcery_config = ::Sorcery::Config

      extend ClassMethods
      include InstanceMethods
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
