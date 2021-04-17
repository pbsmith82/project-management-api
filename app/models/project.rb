class Project < ApplicationRecord
    has_many :stories
    belongs_to :project_type
end
