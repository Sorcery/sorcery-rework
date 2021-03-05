# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    return unless logged_in?

    redirect_back(
      fallback_location: root_path,
      error:             'You\'re already logged in!'
    )
  end

  def create; end

  def destroy; end
end
