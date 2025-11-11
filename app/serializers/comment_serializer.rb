class CommentSerializer
  include FastJsonapi::ObjectSerializer
  
  attributes :id, :content, :created_at, :updated_at
  belongs_to :user
end

