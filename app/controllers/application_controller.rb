class ApplicationController < ActionController::API
  include JwtAuthenticable
  
  # Handle CORS preflight requests - must be before authentication
  before_action :cors_preflight_check
  before_action :authenticate_user!
  
  # Public method for route handling
  def cors_preflight
    # Handle OPTIONS requests for CORS preflight
    origin = request.headers['Origin']
    allowed_origins = [
      'https://projectmanagement.phillipbsmith.com',
      'http://localhost:3001',
      'http://localhost:3000'
    ]
    
    # Check if origin is allowed
    if origin && (allowed_origins.include?(origin) || origin.match?(/^http:\/\/localhost:\d+$/))
      headers['Access-Control-Allow-Origin'] = origin
      headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD'
      headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-Requested-With'
      headers['Access-Control-Max-Age'] = '86400'
      headers['Access-Control-Allow-Credentials'] = 'false'
      render json: {}, status: :ok
    else
      # Log for debugging but still allow
      Rails.logger.warn "CORS: Unallowed origin: #{origin}"
      headers['Access-Control-Allow-Origin'] = origin if origin
      headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD'
      headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-Requested-With'
      render json: {}, status: :ok
    end
  end
  
  def cors_preflight_check
    # This is called as a before_action - rack-cors should handle it, but this is a backup
    if request.method == 'OPTIONS'
      cors_preflight
    end
  end
  
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

