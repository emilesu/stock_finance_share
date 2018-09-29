class AddVideoLink4ToVideos < ActiveRecord::Migration[5.1]
  def change
    add_column :videos, :video_link_4, :string
  end
end
