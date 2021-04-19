class ProjectSerializer
    include FastJsonapi::ObjectSerializer
  
    belongs_to :project_type
    has_many :stories
    attributes :title, :status, :description, :target_date, :start_date, :project_manager, :project_type_id
  
    # attribute :name do |object|
    #   "#{object.name} Part 2"
    # end
  end