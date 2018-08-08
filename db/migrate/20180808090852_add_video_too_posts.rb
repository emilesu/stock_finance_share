class AddVideoTooPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :video_url, :string
    add_column :posts, :video_img, :string
  end
end
