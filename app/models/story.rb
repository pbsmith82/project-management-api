class Story < ApplicationRecord
    belongs_to :project

    validates :title, :description, presence: true

    
    
end
