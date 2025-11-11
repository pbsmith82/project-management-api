class Story < ApplicationRecord
    belongs_to :project
    belongs_to :user, optional: true
    
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings
    has_many_attached :attachments
    
    validates :title, :description, presence: true
    
    after_create :log_activity
    after_update :log_activity
    after_destroy :log_activity
    
    def tag_list
      tags.pluck(:name).join(', ')
    end
    
    def tag_list=(names)
      self.tags = names.split(',').map { |n| Tag.find_or_create_by_name(n) }
    end
    
    private
    
    def log_activity
      action = destroyed? ? 'deleted' : (created_at == updated_at ? 'created' : 'updated')
      ActivityLog.create(
        user_id: user_id,
        action: action,
        record_type: 'Story',
        record_id: id,
        details: "Story #{action}: #{title}"
      ) if user_id
    end
end
