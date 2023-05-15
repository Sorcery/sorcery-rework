# frozen_string_literal: true

module ControllerSpecHelper
  ##
  # Fakes a browser sending HTTP Basic Auth credentials after getting rejected.
  #
  def send_http_basic_auth(username, password)
    request.env['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic.encode_credentials(
        username,
        password
      )
  end

  ##
  # Reloads cookies manually based on the response cookies. Necessary for any
  # test that deletes cookies, needs to make assertions about the results, and
  # does not use the GET verb.
  #
  # In other words, if you're testing cookies but use GET request(s), you do not
  # need to use this workaround.
  #
  # You also don't need this if you're creating or updating cookies. Only
  # deleting cookies is broken.
  #
  # Thanks, I hate it.
  #
  # See: https://github.com/rspec/rspec-rails/issues/1574#issuecomment-373345096
  #
  def reload_cookies
    cookies.update(response.cookies)
  end
end
