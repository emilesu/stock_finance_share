class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :course_id
      t.string :title
      t.text :description
      t.string :catalog
      t.string :section

      t.timestamps
    end
    add_index :posts, :course_id
  end
end
