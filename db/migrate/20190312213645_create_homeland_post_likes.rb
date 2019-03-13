class CreateHomelandPostLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :homeland_post_likes do |t|
      t.integer :user_id, :index => true
      t.integer :homeland_post_id, :index => true
      t.timestamps
    end
  end
end
