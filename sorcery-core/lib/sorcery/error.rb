# frozen_string_literal: true

module Sorcery
  ##
  # Custom error class for rescuing from all Sorcery errors.
  #--
  # TODO: Should this become a module that loads the custom Sorcery errors?
  #++
  #
  class Error < StandardError; end

  # TODO: Other Sorcery specific errors, e.g.:
  # class AuthenticationError < Error; end
end
