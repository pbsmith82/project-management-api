class CreateStories < ActiveRecord::Migration[6.1]
  def change
    create_table :stories do |t|
      t.string :title
      t.string :status
      t.string :active
      t.string :description
      t.string :acceptance_criteria
      t.integer :project_id

      t.timestamps
    end
  end
end
