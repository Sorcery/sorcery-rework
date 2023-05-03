# frozen_string_literal: true

module ControllerSpecHelper
  def send_http_basic_auth(username, password)
    request.env['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic.encode_credentials(
        username,
        password
      )
  end
end
