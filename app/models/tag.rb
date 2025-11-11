class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :projects, through: :taggings, source: :taggable, source_type: 'Project'
  has_many :stories, through: :taggings, source: :taggable, source_type: 'Story'
  
  validates :name, presence: true, uniqueness: true
  
  def self.find_or_create_by_name(name)
    find_or_create_by(name: name.strip.downcase)
  end
end

