class ProjectSerializer
    include FastJsonapi::ObjectSerializer
  
    belongs_to :project_type
    belongs_to :user
    has_many :stories
    has_many :tags
    has_many :comments
    attributes :title, :status, :description, :target_date, :start_date, :project_manager, :project_type_id, :project_type_name, :user_id, :tag_list, :created_at, :updated_at, :risk_score, :risk_level, :predicted_completion_date, :risk_factors, :ai_generated_description
  
    attribute :project_type_name do |object|
      type = ProjectType.find_by_id(object.project_type_id)
      type&.name
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
    
    attribute :risk_level do |object|
      object.risk_level rescue 'low'
    end
    
    attribute :risk_factors do |object|
      object.risk_factors_array rescue []
    end
  end