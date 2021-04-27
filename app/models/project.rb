class Project < ApplicationRecord
    has_many :stories
    belongs_to :project_type

    validates :title, :status, :start_date, presence: true
end
