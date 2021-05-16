# frozen_string_literal: true

class ApiController < ActionController::API
  authenticates_with_sorcery! do |config|
    config.session_store = :jwt_session

    config.load_plugin(:activity_logging)
    config.load_plugin(
      :jwt,
      {
        controller: {
          jwt_secret: Rails.application.secrets.secret_key_base
        }
      }
    )

    config.unload_plugin(:remember_me)
  end

  before_action :require_login

  protected

  def not_authenticated
    render json: { error: 'Please login first.' }, status: :unauthorized
  end
end
