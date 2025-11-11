class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true
  
  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :for_record, ->(type, id) { where(record_type: type, record_id: id) }
end

