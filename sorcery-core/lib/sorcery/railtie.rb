# frozen_string_literal: true

require 'rails'

module Sorcery
  # Sorcery::Railtie extends Rails to automatically support Sorcery.
  #
  # In: `./config/initializers/sorcery.rb`
  #
  # ```
  # Rails.application.config.sorcery.configure do |config|
  #   config.some_variable = true
  #
  #   config.load_plugin(
  #     [...]
  #   )
  #
  #   [etc...]
  # end
  # ```
  class Railtie < ::Rails::Railtie
    # TODO: Do we need to force the namespace with `::Sorcery`?
    config.sorcery = ::Sorcery::Config

    initializer ':extend_rails_with_sorcery' do
      ###########################
      ## ActionController::API ##
      ###########################
      ActiveSupport.on_load(:action_controller_api) do
        # ActionController::API.send :include, ::Sorcery::Controller
        include ::Sorcery::Controller
      end

      ############################
      ## ActionController::Base ##
      ############################
      ActiveSupport.on_load(:action_controller_base) do
        # ActionController::Base.send :include, ::Sorcery::Controller
        include ::Sorcery::Controller
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
        # ActiveRecord::Base.send :extend, ::Sorcery::Model
        extend ::Sorcery::Model

        # TODO: Implement the adapter abstraction layer, consider renaming to
        #       something a little more self-explanatory.
        # define_method(:sorcery_adapter) do
        #   @sorcery_adapter ||=
        #     ::Sorcery::Adapters::ActiveRecordAdapter.new(self)
        # end

        # define_singleton_method(:sorcery_adapter) do
        #   ::Sorcery::Adapters::ActiveRecordAdapter.from(self)
        # end
      end
    end
  end
end
