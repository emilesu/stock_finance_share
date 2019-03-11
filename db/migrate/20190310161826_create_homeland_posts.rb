class CreateHomelandPosts < ActiveRecord::Migration[5.1]
  def change
    create_table :homeland_posts do |t|
      t.integer :user_id
      t.integer :homeland_id
      t.text :description
      t.timestamps
    end
    add_index :homeland_posts, :homeland_id
    add_index :homeland_posts, :user_id
  end
end
