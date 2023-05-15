# frozen_string_literal: true

class RememberMeController < UserSessionsController
  authenticates_with_sorcery! do |config|
    config.load_plugin(:remember_me)
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

  def login_without_remember_me
    if login(params[:username], params[:password])
      head :ok
    else
      head :bad_request
    end
  end

  def page_with_forget_me
    forget_me!
    head :ok
  end

  def page_with_force_forget_me
    force_forget_me!
    head :ok
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

  def login_with_remember_me_parameter
    if login(params[:username], params[:password],
      should_remember: params[:remember])
      head :ok
    else
      head :bad_request
    end
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
