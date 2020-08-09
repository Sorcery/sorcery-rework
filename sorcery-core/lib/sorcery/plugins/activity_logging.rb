# frozen_string_literal: true

module Sorcery
  module Plugins
    ##
    # This plugin adds the ability to track events like login, logout, and last
    # activity time per user. This can be useful in estimating which users are
    # currently active, as well as how long it's been since their last login.
    #
    # This plugin is not absolutely accurate, as it can't detect when a user is
    # reading a page without clicking on anything.
    #
    module ActivityLogging
      autoload :Controller, 'sorcery/plugins/activity_logging/controller'
      autoload :Model, 'sorcery/plugins/activity_logging/model'
    end
  end
end
