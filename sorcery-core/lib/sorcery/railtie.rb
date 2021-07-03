# frozen_string_literal: true

require 'rails'

module Sorcery
  ##
  # Sorcery::Railtie extends Rails to automatically support Sorcery. To do this,
  # it does two things:
  #
  # * Extend <tt>Rails.application.config</tt> with Sorcery::Config
  # * Add on_load hooks for ActionController and ActiveRecord to automatically
  #   extend them with <tt>authenticates_with_sorcery!</tt>. See:
  #   * Sorcery::Controller#authenticates_with_sorcery!
  #   * Sorcery::Model#authenticates_with_sorcery!
  #
  class Railtie < ::Rails::Railtie
    # TODO: Do we need to force the namespace with `::Sorcery`?
    config.sorcery = ::Sorcery::Config

    initializer ':extend_rails_with_sorcery' do
      ###########################
      ## ActionController::API ##
      ###########################
      # FIXME: Can we hook into after JBuilder overloads the API controller to
      #        load our custom helper methods?
      #
      # If you want to use JBuilder, you'll need to call the following in your
      # application_controller.rb:
      #
      # helper_method :current_user
      # helper_method :logged_in?
      ActiveSupport.on_load(:action_controller_api) do
        extend ::Sorcery::Controller
      end

      ############################
      ## ActionController::Base ##
      ############################
      ActiveSupport.on_load(:action_controller_base) do
        extend ::Sorcery::Controller
        # NOTE: `helper_method` is what causes these methods to become available
        #       in views, See:
        #       `ActionController::Helpers::ClassMethods.helper_method`
        helper_method :current_user
        helper_method :logged_in?
      end

      ########################
      ## ActiveRecord::Base ##
      ########################
      ActiveSupport.on_load(:active_record) do
        extend ::Sorcery::Model

        # Define the instance method
        define_method(:sorcery_orm_adapter) do
          @sorcery_orm_adapter ||=
            ::Sorcery::OrmAdapters::ActiveRecord.new(self)
        end

        # Define the class method
        define_singleton_method(:sorcery_orm_adapter) do
          ::Sorcery::OrmAdapters::ActiveRecord.from(self)
        end
      end
    end
  end
end
