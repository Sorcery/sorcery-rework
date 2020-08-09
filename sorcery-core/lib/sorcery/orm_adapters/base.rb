# frozen_string_literal: true

module Sorcery
  module OrmAdapters
    ##
    # Provides common methods to serve as an abstraction for whatever ORM is
    # being used.
    #
    class Base
      def initialize(model)
        @model = model
      end

      def self.from(klass)
        @klass = klass
        self
      end

      def self.delete_all
        @klass.delete_all
      end

      def self.find(id)
        find_by_id(id)
      end

      def increment(field)
        @model.increment(field)
      end

      def update_attribute(name, value)
        update_attributes(name => value)
      end
    end
  end
end
