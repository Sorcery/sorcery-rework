# frozen_string_literal: true

class BruteForceProtectionController < UserSessionsController
  authenticates_with_sorcery! do |config|
    config.load_plugin(:brute_force_protection)
  end
end
