# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :require_login, only: [:index]

  def index; end

  def restricted; end
end
