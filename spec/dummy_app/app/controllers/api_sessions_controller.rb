# frozen_string_literal: true

class ApiSessionsController < ApiController
  skip_before_action :require_login, only: [:new, :create]
  before_action :prevent_double_login, only: [:new, :create]

  def new; end

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
      flash[:success] = 'Logged out successfully!'
    else
      flash[:error] = 'You must be logged in to logout!'
    end

    redirect_to root_path
  end

  private

  def prevent_double_login
    return unless logged_in?

    redirect_back(
      fallback_location: root_path,
      error:             'You\'re already logged in!'
    )
  end
end
