class StorySerializer
    include FastJsonapi::ObjectSerializer
  
    belongs_to :project
    belongs_to :user
    has_many :tags
    has_many :comments
    attributes :id, :title, :description, :status, :acceptance_criteria, :project_id, :project_title, :user_id, :tag_list, :created_at, :updated_at
  
    attribute :project_title do |object|
        project = Project.find_by_id(object.project_id)
        project&.title
    end
    
    attribute :tag_list do |object|
      object.tag_list
    end
    
    attribute :attachments do |object|
      object.attachments.map do |attachment|
        {
          id: attachment.id,
          filename: attachment.filename.to_s,
          url: Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true),
          content_type: attachment.content_type,
          byte_size: attachment.byte_size
        }
      end
    end
  end