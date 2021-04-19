class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :title
      t.string :status
      t.string :description
      t.date :target_date
      t.date :start_date
      t.date :end_date
      t.string :project_manager
      t.integer :project_type_id

      t.timestamps
    end
  end
end
