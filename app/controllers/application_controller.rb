class ApplicationController < ActionController::API
  include JwtAuthenticable
  
  # Skip authentication for OPTIONS requests (CORS preflight handled by rack-cors)
  before_action :authenticate_user!
  
  private
  
  def authenticate_user!
    # Skip authentication for OPTIONS requests (CORS preflight)
    return if request.method == 'OPTIONS'
    
    # Skip authentication for auth endpoints
    return if controller_name == 'auth' && ['login', 'register'].include?(action_name)
    return if controller_name == 'project_types' && action_name == 'index'
    
    token = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless token
    
    decoded = decode_token(token)
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless decoded
    
    @current_user = User.find_by(id: decoded[:user_id])
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end
end

