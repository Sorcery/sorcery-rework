# frozen_string_literal: true

class OAuthController < ApplicationController
  authenticates_with_sorcery! do |config|
    config.load_plugin(:oauth)
  end

  def test_create_from_provider
    provider = params[:provider]
    login_from(provider)
    if (@user = create_from(provider))
      redirect_to 'success_url', notice: 'Success!'
    else
      redirect_to 'failure_url', alert: 'Failed!'
    end
  end
end
