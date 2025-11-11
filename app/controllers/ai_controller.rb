class AIController < ApplicationController
  def generate_description
    title = params[:title]
    project_type = params[:project_type]
    project_manager = params[:project_manager]
    
    description = AIService.generate_project_description(title, project_type: project_type, project_manager: project_manager)
    
    if description
      render json: { description: description, ai_generated: true }
    else
      render json: { error: 'Failed to generate description. Please ensure OPENAI_API_KEY is set.' }, status: :service_unavailable
    end
  end
  
  def generate_acceptance_criteria
    title = params[:title]
    description = params[:description]
    
    criteria = AIService.generate_acceptance_criteria(title, description)
    
    if criteria
      render json: { acceptance_criteria: criteria, ai_generated: true }
    else
      render json: { error: 'Failed to generate acceptance criteria. Please ensure OPENAI_API_KEY is set.' }, status: :service_unavailable
    end
  end
  
  def suggest_tags
    content = params[:content] || ''
    
    tags = AIService.suggest_tags(content)
    
    render json: { tags: tags }
  end
  
  def calculate_risk
    project = Project.find(params[:project_id])
    
    risk_data = AIService.calculate_risk_score(project)
    prediction = AIService.predict_completion_date(project)
    
    # Update project with risk data
    project.update(
      risk_score: risk_data[:score],
      risk_factors: risk_data[:factors].to_json,
      predicted_completion_date: prediction
    )
    
    render json: {
      risk_score: risk_data[:score],
      risk_level: risk_data[:level],
      risk_factors: risk_data[:factors],
      predicted_completion_date: prediction
    }
  end
  
  def generate_insights
    analytics_data = {
      projects: {
        total: Project.count,
        completion_rate: calculate_completion_rate,
        overdue: Project.where("target_date < ? AND status != ?", Date.today, 'Completed').count,
        by_status: Project.group(:status).count
      },
      stories: {
        total: Story.count
      }
    }
    
    insights = AIService.generate_insights(analytics_data)
    
    render json: { insights: insights }
  end
  
  def semantic_search
    query = params[:q] || ''
    limit = params[:limit]&.to_i || 10
    
    if query.blank?
      render json: { data: [] }
      return
    end
    
    projects = Project.all.limit(50)
    results = AIService.semantic_search(query, projects, limit: limit)
    
    if results.any?
      render json: ProjectSerializer.new(results).serializable_hash
    else
      render json: { data: [] }
    end
  end
  
  def find_similar
    project = Project.find(params[:project_id])
    limit = params[:limit]&.to_i || 5
    
    similar = AIService.find_similar_projects(project, limit: limit)
    
    if similar.any?
      render json: ProjectSerializer.new(similar).serializable_hash
    else
      render json: { data: [] }
    end
  end
  
  def detect_duplicates
    project = Project.find(params[:project_id])
    
    duplicates = AIService.detect_duplicates(project)
    
    if duplicates.any?
      render json: ProjectSerializer.new(duplicates).serializable_hash
    else
      render json: { data: [] }
    end
  end
  
  private
  
  def calculate_completion_rate
    total = Project.count
    return 0 if total == 0
    completed = Project.where("status LIKE ?", '%complete%').count
    (completed.to_f / total * 100).round(2)
  end
end

