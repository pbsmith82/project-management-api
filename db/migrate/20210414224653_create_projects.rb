class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :title
      t.string :status
      t.string :target_date
      t.string :start_date
      t.string :end_date
      t.string :project_manager
      t.string :project_type_id

      t.timestamps
    end
  end
end
