class ProjectSerializer
    include FastJsonapi::ObjectSerializer
  
    belongs_to :project_type
    has_many :stories
    attributes :title, :status, :description, :target_date, :start_date, :project_manager, :project_type_id, :project_type_name
  
    attribute :project_type_name do |object|
      type = ProjectType.find_by_id(object.project_type_id)
      type.name
    end
  end