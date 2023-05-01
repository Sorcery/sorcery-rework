# frozen_string_literal: true

class ActivityLoggingController < UserSessionsController
  authenticates_with_sorcery! do |config|
    config.load_plugin(:activity_logging)
  end
end
