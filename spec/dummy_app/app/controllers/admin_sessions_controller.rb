# frozen_string_literal: true

class AdminSessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :prevent_double_login, only: [:new, :create]

  # FIXME: Fix unload_plugin not unloading rails callbacks
  skip_after_action :register_last_activity_time_to_db

  authenticates_with_sorcery! do |config|
    config.user_class = 'Admin'
    config.session_class = 'AdminSession'
    config.session_key = 'admin_session_id'

    config.unload_plugin(:activity_logging)
  end

  def new; end

  def create
    if login(params[:login], params[:password])
      redirect_back_or_to root_path, success: 'Logged in successfully!'
    else
      render :new
    end
  rescue ActiveRecord::RecordInvalid
    redirect_back(
      fallback_location: root_path,
      error:             'You\'re already logged in!'
    )
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
