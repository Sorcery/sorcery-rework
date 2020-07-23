# frozen_string_literal: true

module Sorcery
  module Model # :nodoc:
    def authenticates_with_sorcery!
      @sorcery_config = ::Sorcery::Config.new
    end
  end
end
