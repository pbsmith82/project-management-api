module JwtAuthenticable
  extend ActiveSupport::Concern
  
  SECRET_KEY = Rails.application.credentials.secret_key_base || 'your-secret-key-change-in-production'
  
  def encode_token(payload)
    JWT.encode(payload, SECRET_KEY)
  end
  
  def decode_token(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end
  
  def current_user
    token = request.headers['Authorization']&.split(' ')&.last
    return nil unless token
    
    decoded = decode_token(token)
    return nil unless decoded
    
    @current_user ||= User.find_by(id: decoded[:user_id])
  end
  
  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end
  
  def authorize_user!(resource)
    unless current_user&.can_edit?(resource)
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end
end

