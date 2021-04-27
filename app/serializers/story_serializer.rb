class StorySerializer
    include FastJsonapi::ObjectSerializer
  
    belongs_to :project
    attributes :id, :title, :description, :status, :acceptance_criteria, :project_id, :project_title
  
    attribute :project_title do |object|
        project = Project.find_by_id(object.project_id)
        project.title
      end


  end