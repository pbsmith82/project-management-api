class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login, :register]
  
  def register
    user = User.new(user_params)
    user.role = 'developer' unless user_params[:role]
    
    if user.save
      token = encode_token({ user_id: user.id })
      render json: {
        user: UserSerializer.new(user).serializable_hash,
        token: token
      }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def login
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      token = encode_token({ user_id: user.id })
      render json: {
        user: UserSerializer.new(user).serializable_hash,
        token: token
      }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
  
  def me
    render json: UserSerializer.new(current_user).serializable_hash
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :name, :role)
  end
end

