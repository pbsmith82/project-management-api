class AnalyticsController < ApplicationController
  def index
    analytics_data = {
      projects: project_analytics,
      stories: story_analytics,
      timeline: timeline_data,
      users: user_activity
    }
    
    # Add AI insights if available
    if ENV['OPENAI_API_KEY'].present?
      begin
        insights = AIService.generate_insights(analytics_data)
        analytics_data[:ai_insights] = insights if insights
      rescue => e
        Rails.logger.error("Failed to generate AI insights: #{e.message}")
      end
    end
    
    render json: analytics_data
  end
  
  private
  
  def project_analytics
    {
      total: Project.count,
      by_status: Project.group(:status).count,
      by_type: Project.joins(:project_type).group('project_types.name').count,
      completion_rate: calculate_completion_rate,
      overdue: Project.where("target_date < ? AND status != ?", Date.today, 'Completed').count
    }
  end
  
  def story_analytics
    {
      total: Story.count,
      by_status: Story.group(:status).count,
      average_per_project: Project.joins(:stories).group('projects.id').count.values.sum.to_f / Project.count,
      completed: Story.where("status LIKE ?", '%complete%').count
    }
  end
  
  def timeline_data
    # Projects created over last 30 days
    (0..29).map do |days_ago|
      date = Date.today - days_ago
      {
        date: date.to_s,
        projects_created: Project.where(created_at: date.beginning_of_day..date.end_of_day).count,
        stories_created: Story.where(created_at: date.beginning_of_day..date.end_of_day).count
      }
    end.reverse
  end
  
  def user_activity
    ActivityLog.group(:user_id)
               .joins(:user)
               .group('users.name')
               .count
               .map { |name, count| { user: name, activities: count } }
  end
  
  def calculate_completion_rate
    total = Project.count
    return 0 if total == 0
    completed = Project.where("status LIKE ?", '%complete%').count
    (completed.to_f / total * 100).round(2)
  end
end

