# frozen_string_literal: true

class HttpBasicAuthController < ApplicationController
  authenticates_with_sorcery! do |config|
    config.load_plugin(
      :http_basic_auth,
      controller: {
        controller_to_realm_map: { http_basic_auth: 'HttpBasicAuth' }
      }
    )
  end

  skip_before_action :require_login
  before_action :require_login_from_http_basic

  def restricted_with_http_basic_auth
    head :ok
  end
end
