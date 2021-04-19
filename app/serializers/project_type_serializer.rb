class ProjectTypeSerializer
    include FastJsonapi::ObjectSerializer
  
    has_many :projects
    attributes :description
  
    # attribute :name do |object|
    #   "#{object.name} Part 2"
    # end
  end