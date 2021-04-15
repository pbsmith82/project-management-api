class CreateStories < ActiveRecord::Migration[6.1]
  def change
    create_table :stories do |t|
      t.string :story_status
      t.string :story_active
      t.string :description
      t.string :acceptance_criteria
      t.string :project_id

      t.timestamps
    end
  end
end
