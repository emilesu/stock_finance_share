class CreatePhotos < ActiveRecord::Migration[5.1]
  def change
    create_table :photos do |t|
      t.string :image
      t.timestamps
    end
    add_column :photos,:user_id,:integer
    add_index :photos, :user_id
  end
end
