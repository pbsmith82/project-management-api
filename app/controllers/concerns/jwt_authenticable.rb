module JwtAuthenticable
  extend ActiveSupport::Concern
  
  def secret_key
    @secret_key ||= begin
      if Rails.application.credentials.respond_to?(:secret_key_base) && Rails.application.credentials.secret_key_base.present?
        Rails.application.credentials.secret_key_base
      elsif ENV['SECRET_KEY_BASE'].present?
        ENV['SECRET_KEY_BASE']
      else
        'your-secret-key-change-in-production'
      end
    end
  end
  
  def encode_token(payload)
    JWT.encode(payload, secret_key)
  end
  
  def decode_token(token)
    decoded = JWT.decode(token, secret_key)[0]
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

