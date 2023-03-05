# frozen_string_literal: true

module Sorcery
  module Plugins
    ##
    #
    module RememberMe
      autoload :Controller, 'sorcery/plugins/remember_me/controller'
      autoload :Model, 'sorcery/plugins/remember_me/model'
    end
  end
end
