class CreateLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :likes do |t|
      t.integer :user_id, :index => true
      t.integer :note_id, :index => true
      t.timestamps
    end
  end
end
