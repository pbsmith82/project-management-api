class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  
  validates :content, presence: true
  
  after_create :log_activity
  after_destroy :log_activity
  
  private
  
  def log_activity
    ActivityLog.create(
      user_id: user_id,
      action: 'commented',
      record_type: commentable_type,
      record_id: commentable_id,
      details: "Comment #{persisted? ? 'created' : 'deleted'}"
    )
  end
end

