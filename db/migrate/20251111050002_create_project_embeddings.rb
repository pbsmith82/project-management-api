class CreateProjectEmbeddings < ActiveRecord::Migration[6.1]
  def change
    create_table :project_embeddings do |t|
      t.integer :project_id
      t.text :embedding

      t.timestamps
    end
    add_index :project_embeddings, :project_id
  end
end

