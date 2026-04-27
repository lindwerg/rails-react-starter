class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :handle_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_bad_request

  before_action :authenticate!

  attr_reader :current_user

  private

  def authenticate!
    token = bearer_token || cookies.signed[:jwt]
    return render_unauthenticated unless token

    payload = Auth::JwtVerifier.call(token)
    @current_user = User.find_by(id: payload[:user_id])
    render_unauthenticated unless @current_user
  rescue Auth::InvalidToken
    render_unauthenticated
  end

  def bearer_token
    header = request.headers["Authorization"]
    return nil unless header

    header.split(" ").last
  end

  def render_unauthenticated
    render json: { error: "Unauthenticated" }, status: :unauthorized
  end

  def handle_forbidden
    render json: { error: "Forbidden" }, status: :forbidden
  end

  def handle_not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def handle_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
