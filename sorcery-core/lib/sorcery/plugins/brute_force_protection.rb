# frozen_string_literal: true

module Sorcery
  module Plugins
    ##
    # This plugin protects user accounts from brute force attacks by locking
    # them down after a number of failed attempts are detected.
    #
    module BruteForceProtection
      autoload :Controller, 'sorcery/plugins/brute_force_protection/controller'
      autoload :Model, 'sorcery/plugins/brute_force_protection/model'
    end
  end
end
