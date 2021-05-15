# frozen_string_literal: true

class ApiController < ActionController::API
  authenticates_with_sorcery! do |config|
    config.session_store = :jwt_session

    config.load_plugin(:activity_logging)
    config.load_plugin(:jwt)
  end

  before_action :require_login

  protected

  def not_authenticated
    render json: { error: 'Please login first.' }, status: :unauthorized
  end
end
