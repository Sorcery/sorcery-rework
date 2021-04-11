# frozen_string_literal: true

require 'sorcery-core'

module Sorcery
  module Plugins # :nodoc:
    # FIXME: This seems like it might be really dumb. That said, it allows
    #        plugins to define their own const mapping without upstream changes.
    #        Double check that this is sane, and that there aren't any other
    #        better solutions.
    PLUGIN_CONST_MAPPING[:mfa] = 'MFA'

    autoload :MFA, 'sorcery/plugins/mfa'
  end
end
