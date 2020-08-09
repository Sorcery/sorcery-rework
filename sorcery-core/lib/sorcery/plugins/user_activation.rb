# frozen_string_literal: true

module Sorcery
  module Plugins
    ##
    #
    module UserActivation
      autoload :Controller, 'sorcery/plugins/user_activation/controller'
      autoload :Model, 'sorcery/plugins/user_activation/model'
    end
  end
end
