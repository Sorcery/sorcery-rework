# frozen_string_literal: true

class ApiSessionsController < ApiController
  skip_before_action :require_login, only: [:create]
  before_action :prevent_double_login, only: [:create]

  def create
    if (session_jwt_token = login(params[:login], params[:password]))
      render json: { session_token: session_jwt_token }
      redirect_back_or_to root_path, success: 'Logged in successfully!'
    else
      render json: { error: 'Failed to login' }, status: :bad_request
    end
  end

  def destroy
    if logged_in?
      logout
      head :ok
    else
      render json: { error: 'You must be logged in to logout!' },
        status: :bad_request
    end
  end

  private

  def prevent_double_login
    return unless logged_in?

    render json: { error: 'You\'re already logged in!' }, status: :bad_request
  end
end
