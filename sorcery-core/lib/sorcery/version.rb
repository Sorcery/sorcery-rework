# frozen_string_literal: true

module Sorcery
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 0
    PATCH = 0

    STRING = [MAJOR, MINOR, PATCH].join('.')
  end
end
