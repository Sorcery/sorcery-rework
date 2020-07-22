# frozen_string_literal: true

module Sorcery
  # Sorcery::Engine extends Rails with our custom logic.
  class Engine < Rails::Engine
    # Add support for calling `Rails.application.config.sorcery`
    # TODO: Do we need to force the namespace with `::Sorcery`?
    config.sorcery = ::Sorcery::Config
  end
end
