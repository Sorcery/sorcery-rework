# frozen_string_literal: true

class SessionTimeoutController < UserSessionsController
  authenticates_with_sorcery! do |config|
    config.load_plugin(:session_timeout)
  end

  skip_before_action :require_login, except: [:destroy]

  def login_with_remember_me
    if login(params[:username], params[:password])
      remember_me!
      head :ok
    else
      head :bad_request
    end
  end

  def purge_session
    logout(skip_callbacks: true)
    head :ok
  end

  def show_if_logged_in
    if logged_in?
      flash[:success] = 'You are logged in!'
    else
      flash[:warning] = 'You are not logged in!'
    end

    head :ok
  end

  def invalidate_sessions
    invalidate_active_sessions!
    head :ok
  end
end
