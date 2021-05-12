# frozen_string_literal: true

class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :prevent_double_login, only: [:new, :create]

  def new; end

  def create
    if login(params[:login], params[:password])
      redirect_back_or_to root_path, success: 'Logged in successfully!'
    else
      render :new
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
