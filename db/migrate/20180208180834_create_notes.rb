class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.integer :stock_id
      t.integer :user_id
      t.string :status
      t.string :level
      t.string :title
      t.text :description
      t.timestamps
    end
    add_index :notes, :status
  end
end
