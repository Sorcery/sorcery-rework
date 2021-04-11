# frozen_string_literal: true

require 'sorcery-core'

module Sorcery
  ##
  #
  module Plugins
    # FIXME: This seems like it might be really dumb. That said, it allows
    #        plugins to define their own const mapping without upstream changes.
    #        Double check that this is sane, and that there aren't any other
    #        better solutions.
    PLUGIN_CONST_MAPPING[:oauth] = 'OAuth'

    autoload :OAuth, 'sorcery/plugins/oauth'
  end

  ##
  # OAuth protocols, used by including the appropriate protocol in a provider
  # class.
  #
  module Protocols
    autoload :OAuth, 'sorcery/protocols/oauth'
    autoload :OAuth2, 'sorcery/protocols/oauth2'
  end

  ##
  # OAuth Providers
  #
  module Providers
    autoload :Auth0, 'sorcery/providers/auth0'
    autoload :Base, 'sorcery/providers/base'
    autoload :Discord, 'sorcery/providers/discord'
    autoload :Facebook, 'sorcery/providers/facebook'
    autoload :Twitter, 'sorcery/providers/twitter'
    autoload :VK, 'sorcery/providers/vk'
    autoload :LinkedIn, 'sorcery/providers/linkedin'
    autoload :LiveID, 'sorcery/providers/liveid'
    autoload :Github, 'sorcery/providers/github'
    autoload :Heroku, 'sorcery/providers/heroku'
    autoload :Google, 'sorcery/providers/google'
    autoload :Jira, 'sorcery/providers/jira'
    autoload :Salesforce, 'sorcery/providers/salesforce'
    autoload :PayPal, 'sorcery/providers/paypal'
    autoload :Slack, 'sorcery/providers/slack'
    autoload :Microsoft, 'sorcery/providers/microsoft'
    autoload :Instagram, 'sorcery/providers/instagram'
    autoload :Line, 'sorcery/providers/line'
    autoload :WeChat, 'sorcery/providers/wechat'
    autoload :Xing, 'sorcery/providers/xing'
  end
end
