module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    
    def connect
      user = find_verified_user
      if user
        self.current_user = user
      else
        reject_unauthorized_connection
      end
    end
    
    private
    
    def find_verified_user
      # Action Cable sends token as query parameter
      token = request.params[:token]
      unless token
        reject_unauthorized_connection
        return nil
      end
      
      decoded = decode_token(token)
      unless decoded
        reject_unauthorized_connection
        return nil
      end
      
      user = User.find_by(id: decoded[:user_id])
      unless user
        reject_unauthorized_connection
        return nil
      end
      
      user
    end
    
    def decode_token(token)
      secret = Rails.application.credentials.secret_key_base || 'your-secret-key-change-in-production'
      decoded = JWT.decode(token, secret)[0]
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError
      nil
    end
    
    def reject_unauthorized_connection
      # Connection will be rejected
    end
  end
end
