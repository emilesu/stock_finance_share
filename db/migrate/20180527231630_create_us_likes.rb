class CreateUsLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :us_likes do |t|
      t.integer :user_id, :index => true
      t.integer :us_note_id, :index => true
      t.timestamps
    end
  end
end
