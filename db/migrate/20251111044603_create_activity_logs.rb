class CreateActivityLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :activity_logs do |t|
      t.integer :user_id
      t.string :action
      t.string :record_type
      t.integer :record_id
      t.text :details

      t.timestamps
    end
  end
end
