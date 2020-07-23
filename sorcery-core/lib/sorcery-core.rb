# frozen_string_literal: true

# require 'rails'
# require 'active_support/core_ext/numeric/time'
# require 'active_support/dependencies'

# TODO: Documentation
module Sorcery # :nodoc:
  autoload :Config, 'sorcery/config'
  autoload :Engine, 'sorcery/engine'
  autoload :VERSION, 'sorcery/version'

  module Plugins # :nodoc:
    autoload :Core, 'sorcery/plugins/core'
  end
end
