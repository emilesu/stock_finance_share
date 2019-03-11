class CreateHomelands < ActiveRecord::Migration[5.1]
  def change
    create_table :homelands do |t|
      t.integer :user_id
      t.string :categories
      t.string :title
      t.text :description
      t.timestamps
    end
    add_index :homelands, :categories
    add_index :homelands, :user_id
  end
end
