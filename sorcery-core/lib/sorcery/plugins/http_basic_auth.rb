# frozen_string_literal: true

module Sorcery
  module Plugins
    ##
    #
    module HttpBasicAuth
      autoload :Controller, 'sorcery/plugins/http_basic_auth/controller'
      autoload :Model, 'sorcery/plugins/http_basic_auth/model'
    end
  end
end
