class Project < ApplicationRecord
    has_many :stories, dependent: :destroy
    belongs_to :project_type, optional: true
    belongs_to :user, optional: true
    has_one :project_embedding, dependent: :destroy
    
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings
    has_many_attached :attachments
    
    validates :title, :status, presence: true
    validates :start_date, presence: true, on: :create
    
    after_save :update_embedding, if: -> { saved_change_to_title? || saved_change_to_description? }
    after_create :calculate_initial_risk
    
    after_create :log_activity
    after_update :log_activity
    after_destroy :log_activity
    
    def tag_list
      tags.pluck(:name).join(', ')
    end
    
    def tag_list=(names)
      self.tags = names.split(',').map { |n| Tag.find_or_create_by_name(n) }
    end
    
    def risk_level
      return 'low' unless risk_score
      case risk_score.to_f
      when 0..30
        'low'
      when 31..60
        'medium'
      when 61..80
        'high'
      else
        'critical'
      end
    rescue => e
      Rails.logger.error("Error calculating risk_level: #{e.message}")
      'low'
    end
    
    def risk_factors_array
      return [] unless risk_factors
      JSON.parse(risk_factors) rescue []
    rescue => e
      Rails.logger.error("Error parsing risk_factors: #{e.message}")
      []
    end
    
    private
    
    def update_embedding
      return unless title.present? || description.present?
      return unless AIService::OPENAI_API_KEY.present?
      
      # Generate embedding asynchronously (in production, use background job)
      Thread.new do
        begin
          text = "#{title} #{description}".strip
          embedding = AIService.generate_embedding(text)
          if embedding
            ProjectEmbedding.find_or_create_by(project_id: id) do |pe|
              pe.embedding = embedding.to_json
            end
          end
        rescue => e
          Rails.logger.error("Error updating embedding: #{e.message}")
        end
      end
    end
    
    def calculate_initial_risk
      Thread.new do
        begin
          risk_data = AIService.calculate_risk_score(self)
          prediction = AIService.predict_completion_date(self)
          update_columns(
            risk_score: risk_data[:score],
            risk_factors: risk_data[:factors].to_json,
            predicted_completion_date: prediction
          )
        rescue => e
          Rails.logger.error("Error calculating initial risk: #{e.message}")
          # Set default values if calculation fails
          update_columns(
            risk_score: 0.0,
            risk_factors: [].to_json,
            predicted_completion_date: target_date
          )
        end
      end
    end
    
    def log_activity
      action = destroyed? ? 'deleted' : (created_at == updated_at ? 'created' : 'updated')
      ActivityLog.create(
        user_id: user_id,
        action: action,
        record_type: 'Project',
        record_id: id,
        details: "Project #{action}: #{title}"
      ) if user_id
    end
end
