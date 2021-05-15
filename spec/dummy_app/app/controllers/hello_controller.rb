# frozen_string_literal: true

class HelloController < ApiController
  skip_before_action :require_login, only: [:index]

  def index
    render json: { hello: 'there' }
  end

  def restricted
    render json: { restricted: 'content here' }
  end
end
