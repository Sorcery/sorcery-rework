# frozen_string_literal: true

module Sorcery
  module Plugins
    ##
    #
    module SessionTimeout
      autoload :Controller, 'sorcery/plugins/session_timeout/controller'
      autoload :Model, 'sorcery/plugins/session_timeout/model'
    end
  end
end
