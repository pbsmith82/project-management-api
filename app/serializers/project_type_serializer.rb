class ProjectTypeSerializer
    include FastJsonapi::ObjectSerializer
  
    has_many :projects
    attributes :id, :name, :description
  
    # attribute :name do |object|
    #   "#{object.name} Part 2"
    # end
  end