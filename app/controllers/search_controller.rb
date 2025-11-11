class SearchController < ApplicationController
  def index
    query = params[:q] || ''
    filters = params[:filters] || {}
    
    results = {
      projects: search_projects(query, filters),
      stories: search_stories(query, filters)
    }
    
    render json: results
  end
  
  private
  
  def search_projects(query, filters)
    projects = Project.all
    
    # Text search
    if query.present?
      projects = projects.where(
        "title LIKE ? OR description LIKE ?",
        "%#{query}%", "%#{query}%"
      )
    end
    
    # Filters
    projects = projects.where(status: filters[:status]) if filters[:status].present?
    projects = projects.where(project_type_id: filters[:project_type_id]) if filters[:project_type_id].present?
    projects = projects.where(user_id: filters[:user_id]) if filters[:user_id].present?
    
    # Date range
    if filters[:start_date].present?
      projects = projects.where("start_date >= ?", filters[:start_date])
    end
    if filters[:end_date].present?
      projects = projects.where("target_date <= ?", filters[:end_date])
    end
    
    # Tags
    if filters[:tags].present?
      tag_names = filters[:tags].split(',')
      projects = projects.joins(:tags).where(tags: { name: tag_names }).distinct
    end
    
    ProjectSerializer.new(projects.limit(50)).serializable_hash
  end
  
  def search_stories(query, filters)
    stories = Story.all
    
    # Text search
    if query.present?
      stories = stories.where(
        "title LIKE ? OR description LIKE ? OR acceptance_criteria LIKE ?",
        "%#{query}%", "%#{query}%", "%#{query}%"
      )
    end
    
    # Filters
    stories = stories.where(status: filters[:story_status]) if filters[:story_status].present?
    stories = stories.where(project_id: filters[:project_id]) if filters[:project_id].present?
    
    # Tags
    if filters[:tags].present?
      tag_names = filters[:tags].split(',')
      stories = stories.joins(:tags).where(tags: { name: tag_names }).distinct
    end
    
    StorySerializer.new(stories.limit(50)).serializable_hash
  end
end

