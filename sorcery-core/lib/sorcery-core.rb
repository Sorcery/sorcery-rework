# frozen_string_literal: true

# TODO: Documentation
module Sorcery # :nodoc:
  ####################################
  ## Add Autoload Paths for Sorcery ##
  ####################################
  autoload :Config, 'sorcery/config'
  autoload :Controller, 'sorcery/controller'
  autoload :Model, 'sorcery/model'
  autoload :VERSION, 'sorcery/version'

  module Plugins # :nodoc:
    autoload :Core, 'sorcery/plugins/core'
  end

  ###############################
  ## Extend Rails with Sorcery ##
  ###############################
  require 'sorcery/railtie'
end
