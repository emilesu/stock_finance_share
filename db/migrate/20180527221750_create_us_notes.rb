class CreateUsNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :us_notes do |t|
      t.integer :us_stock_id
      t.integer :user_id
      t.string :status, :default => "公开"
      t.string :level, :default => "近期关注"
      t.string :title
      t.text :description
      t.timestamps
    end
    add_index :us_notes, :status
    add_index :us_notes, :us_stock_id
    add_index :us_notes, :user_id
  end
end
