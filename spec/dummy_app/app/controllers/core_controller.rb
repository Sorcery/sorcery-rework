# frozen_string_literal: true

class CoreController < UserSessionsController
  skip_before_action :require_login, only: [:login_with_login_as_user]

  def restricted
    head :ok
  end

  def login_with_login_as_user
    user = User.find_by(username: params[:username])
    login_as_user(user)

    if logged_in?
      head :ok
    else
      head :bad_request
    end
  end
end
