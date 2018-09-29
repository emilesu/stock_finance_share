class CreateVideos < ActiveRecord::Migration[5.1]
  def change
    create_table :videos do |t|
      t.string :title
      t.text :description
      t.string :cover
      t.string :video_link_1
      t.string :video_link_2
      t.string :video_link_3

      t.timestamps
    end
  end
end
