class CreateProjectTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :project_types do |t|
      t.string :description

      t.timestamps
    end
  end
end
