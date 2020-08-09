# frozen_string_literal: true

module Sorcery
  module Plugins
    ##
    #
    module ResetPassword
      autoload :Controller, 'sorcery/plugins/reset_password/controller'
      autoload :Model, 'sorcery/plugins/reset_password/model'
    end
  end
end
