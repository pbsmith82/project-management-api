class AddAiFieldsToStories < ActiveRecord::Migration[6.1]
  def change
    add_column :stories, :ai_generated_acceptance_criteria, :boolean, default: false
    add_column :stories, :embedding, :text
  end
end

