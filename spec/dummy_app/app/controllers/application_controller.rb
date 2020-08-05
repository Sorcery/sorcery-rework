# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery
  authenticates_with_sorcery! do |config|
    config.plugins = [:core, :mfa, :oauth]
  end

  before_action :require_login

  protected

  def not_authenticated
    redirect_to root_path, alert: 'Please login first.'
  end
end
