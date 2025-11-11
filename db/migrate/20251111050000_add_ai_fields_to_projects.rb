class AddAiFieldsToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :ai_generated_description, :boolean, default: false
    add_column :projects, :predicted_completion_date, :date
    add_column :projects, :risk_score, :decimal, precision: 5, scale: 2
    add_column :projects, :risk_factors, :text
  end
end

