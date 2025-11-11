class CreateTaggings < ActiveRecord::Migration[6.1]
  def change
    create_table :taggings do |t|
      t.integer :tag_id
      t.string :taggable_type
      t.integer :taggable_id

      t.timestamps
    end
    add_index :taggings, [:taggable_type, :taggable_id]
    add_index :taggings, :tag_id
  end
end
