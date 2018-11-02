class CreateNews < ActiveRecord::Migration[5.1]
  def change
    create_table :news do |t|
      t.string :title
      t.text :description
      t.string :image
      t.datetime :up_time
      t.string :link_1
      t.string :link_1_info
      t.string :link_2
      t.string :link_2_info
      t.timestamps
    end
  end
end
