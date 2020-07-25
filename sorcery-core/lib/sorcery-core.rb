# frozen_string_literal: true

# TODO: Documentation
module Sorcery # :nodoc:
  autoload :Config, 'sorcery/config'
  autoload :Controller, 'sorcery/controller'
  autoload :Engine, 'sorcery/engine'
  autoload :Model, 'sorcery/model'
  autoload :VERSION, 'sorcery/version'

  module Plugins # :nodoc:
    autoload :Core, 'sorcery/plugins/core'
  end
end
