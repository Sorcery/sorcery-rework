# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery
  authenticates_with_sorcery!

  before_action :require_login

  add_flash_types :error, :success, :alert

  protected

  def not_authenticated
    redirect_to root_path, alert: 'Please login first.'
  end
end
