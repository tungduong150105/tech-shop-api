class ApplicationController < ActionController::API
  before_action :authenticate_user

  private

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    if token
      @current_user = User.from_token(token)

      if @current_user.nil?
        render json: { errors: "Invalid or expired token" }, status: :unauthorized
      end
    else
      render json: { errors: "Missing token" }, status: :unauthorized
    end
  end

  def current_user
    puts "Current User: #{@current_user}"
    @current_user
  end

  def require_admin
    # unless current_user&.admin?
    #   render json: { error: "Admin access required" }, status: :forbidden
    # end
  end

  def require_customer
    # unless current_user&.customer?
    #   render json: { error: "Customer access required" }, status: :forbidden
    # end
  end
end
