class AIService
  require 'openai'
  require 'json'
  
  OPENAI_API_KEY = ENV['OPENAI_API_KEY'] || Rails.application.credentials.dig(:openai, :api_key) rescue nil
  OPENAI_MODEL = 'gpt-4o-mini' # Using cheaper model for cost efficiency
  
  class << self
    def generate_project_description(title, project_type: nil, project_manager: nil)
      return nil unless OPENAI_API_KEY.present?
      return nil if title.blank?
      
      prompt = build_project_description_prompt(title, project_type, project_manager)
      call_openai(prompt, max_tokens: 200)
    end
    
    def generate_acceptance_criteria(story_title, story_description)
      return nil unless OPENAI_API_KEY.present?
      return nil if story_title.blank?
      
      prompt = build_acceptance_criteria_prompt(story_title, story_description)
      call_openai(prompt, max_tokens: 300)
    end
    
    def suggest_tags(content)
      return [] unless OPENAI_API_KEY.present?
      return [] if content.blank?
      
      prompt = "Based on the following content, suggest 3-5 relevant tags (single words or short phrases). Return only a comma-separated list:\n\n#{content}"
      result = call_openai(prompt, max_tokens: 50)
      return [] unless result
      
      result.split(',').map(&:strip).reject(&:empty?)
    end
    
    def generate_embedding(text)
      return nil unless OPENAI_API_KEY.present?
      return nil if text.blank?
      
      client = OpenAI::Client.new(access_token: OPENAI_API_KEY)
      
      begin
        response = client.embeddings(
          parameters: {
            model: 'text-embedding-3-small',
            input: text
          }
        )
        
        response.dig('data', 0, 'embedding')
      rescue => e
        Rails.logger.error("OpenAI embedding error: #{e.message}")
        nil
      end
    end
    
    def semantic_search(query, projects, limit: 5)
      return [] unless OPENAI_API_KEY.present?
      return [] if query.blank? || projects.empty?
      
      query_embedding = generate_embedding(query)
      return [] unless query_embedding
      
      # Calculate cosine similarity
      similarities = projects.map do |project|
        project_embedding = get_project_embedding(project)
        next nil unless project_embedding
        
        begin
          embedding_array = JSON.parse(project_embedding)
          similarity = cosine_similarity(query_embedding, embedding_array)
          { project: project, similarity: similarity }
        rescue => e
          Rails.logger.error("Error calculating similarity: #{e.message}")
          nil
        end
      end.compact
      
      # Filter by minimum similarity threshold (0.7)
      filtered = similarities.select { |s| s[:similarity] >= 0.7 }
      filtered.sort_by { |s| -s[:similarity] }.first(limit).map { |s| s[:project] }
    end
    
    def find_similar_projects(project, limit: 5)
      return [] unless project.id && (project.title.present? || project.description.present?)
      
      query = "#{project.title} #{project.description}".strip
      return [] if query.blank?
      
      similar = Project.where.not(id: project.id).limit(50)
      
      if OPENAI_API_KEY.present?
        semantic_search(query, similar, limit: limit)
      else
        # Fallback to simple text matching
        similar.where("title LIKE ? OR description LIKE ?", "%#{project.title}%", "%#{project.description}%")
               .limit(limit)
               .to_a
      end
    end
    
    def detect_duplicates(project)
      return [] unless project.id && (project.title.present? || project.description.present?)
      
      query = "#{project.title} #{project.description}".strip
      return [] if query.blank?
      
      # First do a simple text search for candidates
      candidates = Project.where.not(id: project.id)
                          .where("title LIKE ? OR description LIKE ?", "%#{project.title}%", "%#{project.description}%")
                          .limit(20)
      
      return [] if candidates.empty?
      
      # If OpenAI is available, use semantic search, otherwise return text matches
      if OPENAI_API_KEY.present?
        semantic_search(query, candidates, limit: 3)
      else
        candidates.limit(3).to_a
      end
    end
    
    def predict_completion_date(project)
      return nil unless project.start_date && project.target_date
      
      # Simple prediction based on historical data
      similar_projects = Project.where(project_type_id: project.project_type_id)
                                .where.not(id: project.id)
                                .where.not(status: ['Pending', 'On Hold'])
      
      return project.target_date if similar_projects.empty?
      
      # Calculate average completion time
      completed_projects = similar_projects.where("status LIKE ?", '%complete%')
      
      if completed_projects.any?
        avg_days = completed_projects.map do |p|
          next nil unless p.start_date
          # Use updated_at as completion date if no end_date field exists
          end_date = p.respond_to?(:end_date) ? p.end_date : p.updated_at.to_date
          next nil unless end_date
          (end_date - p.start_date).to_i
        end.compact
        
        return project.target_date if avg_days.empty?
        
        avg_duration = avg_days.sum.to_f / avg_days.length
        predicted_date = project.start_date + avg_duration.days
      else
        # Use target date as baseline
        predicted_date = project.target_date
      end
      
      predicted_date
    end
    
    def calculate_risk_score(project)
      risk_factors = []
      score = 0.0
      
      # Check if overdue
      if project.target_date && project.target_date < Date.today && project.status != 'Completed'
        score += 30
        risk_factors << "Project is overdue"
      end
      
      # Check story completion rate
      if project.stories.any?
        total_stories = project.stories.count
        completed_stories = project.stories.where("status LIKE ?", '%complete%').count
        completion_rate = (completed_stories.to_f / total_stories) * 100
        
        if completion_rate < 50 && project.target_date && project.target_date < (Date.today + 7.days)
          score += 25
          risk_factors << "Low story completion rate (#{completion_rate.round}%)"
        end
      end
      
      # Check if approaching deadline
      if project.target_date
        days_remaining = (project.target_date - Date.today).to_i
        if days_remaining > 0 && days_remaining < 7
          score += 20
          risk_factors << "Approaching deadline (#{days_remaining} days remaining)"
        end
      end
      
      # Check project status
      if project.status == 'On Hold'
        score += 15
        risk_factors << "Project is on hold"
      end
      
      # Check if no stories
      if project.stories.empty? && project.target_date && project.target_date < (Date.today + 14.days)
        score += 10
        risk_factors << "No stories defined"
      end
      
      score = [score, 100.0].min
      
      {
        score: score.round(2),
        level: risk_level(score),
        factors: risk_factors
      }
    end
    
    def generate_insights(analytics_data)
      return nil unless OPENAI_API_KEY.present?
      
      prompt = build_insights_prompt(analytics_data)
      call_openai(prompt, max_tokens: 400)
    end
    
    private
    
    def call_openai(prompt, max_tokens: 200)
      return nil unless OPENAI_API_KEY.present?
      return nil if prompt.blank?
      
      client = OpenAI::Client.new(access_token: OPENAI_API_KEY)
      
      begin
        response = client.chat(
          parameters: {
            model: OPENAI_MODEL,
            messages: [
              { role: 'system', content: 'You are a helpful project management assistant.' },
              { role: 'user', content: prompt }
            ],
            max_tokens: max_tokens,
            temperature: 0.7
          }
        )
        
        response.dig('choices', 0, 'message', 'content')&.strip
      rescue => e
        Rails.logger.error("OpenAI API error: #{e.message}")
        nil
      end
    end
    
    def build_project_description_prompt(title, project_type, project_manager)
      parts = ["Generate a professional project description for a project titled: #{title}"]
      parts << "Project type: #{project_type}" if project_type
      parts << "Project manager: #{project_manager}" if project_manager
      parts << "The description should be 2-3 sentences, professional, and highlight the project's purpose and goals."
      parts.join("\n")
    end
    
    def build_acceptance_criteria_prompt(title, description)
      "Generate acceptance criteria for a user story with the following details:\n\nTitle: #{title}\n\nDescription: #{description}\n\nProvide 3-5 clear, testable acceptance criteria. Format as a bulleted list."
    end
    
    def build_insights_prompt(analytics_data)
      "Analyze the following project management analytics and provide 3-4 key insights and recommendations:\n\n" +
      "Total Projects: #{analytics_data[:projects][:total]}\n" +
      "Completion Rate: #{analytics_data[:projects][:completion_rate]}%\n" +
      "Overdue Projects: #{analytics_data[:projects][:overdue]}\n" +
      "Total Stories: #{analytics_data[:stories][:total]}\n" +
      "Projects by Status: #{analytics_data[:projects][:by_status].to_json}\n\n" +
      "Provide actionable insights in a professional tone."
    end
    
    def get_project_embedding(project)
      return nil unless OPENAI_API_KEY.present?
      
      embedding_record = ProjectEmbedding.find_by(project_id: project.id)
      return embedding_record.embedding if embedding_record
      
      # Generate and store embedding
      text = "#{project.title} #{project.description}".strip
      return nil if text.blank?
      
      embedding = generate_embedding(text)
      return nil unless embedding
      
      begin
        ProjectEmbedding.create(
          project_id: project.id,
          embedding: embedding.to_json
        )
        embedding.to_json
      rescue => e
        Rails.logger.error("Error storing embedding: #{e.message}")
        nil
      end
    end
    
    def cosine_similarity(vec1, vec2)
      return 0.0 unless vec1.is_a?(Array) && vec2.is_a?(Array)
      return 0.0 if vec1.length != vec2.length
      return 0.0 if vec1.empty? || vec2.empty?
      
      begin
        dot_product = vec1.zip(vec2).map { |a, b| a.to_f * b.to_f }.sum
        magnitude1 = Math.sqrt(vec1.map { |x| x.to_f * x.to_f }.sum)
        magnitude2 = Math.sqrt(vec2.map { |x| x.to_f * x.to_f }.sum)
        
        return 0.0 if magnitude1.zero? || magnitude2.zero?
        
        dot_product / (magnitude1 * magnitude2)
      rescue => e
        Rails.logger.error("Error calculating cosine similarity: #{e.message}")
        0.0
      end
    end
    
    def risk_level(score)
      case score
      when 0..30
        'low'
      when 31..60
        'medium'
      when 61..80
        'high'
      else
        'critical'
      end
    end
  end
end

