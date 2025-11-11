class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, inclusion: { in: %w[admin project_manager developer] }
  
  has_many :projects, dependent: :nullify
  has_many :stories, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  
  def admin?
    role == 'admin'
  end
  
  def project_manager?
    role == 'project_manager' || admin?
  end
  
  def can_edit?(resource)
    return true if admin?
    return true if resource.respond_to?(:user_id) && resource.user_id == id
    false
  end
  
  def can_delete?(resource)
    admin? || (resource.respond_to?(:user_id) && resource.user_id == id)
  end
end

