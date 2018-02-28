class AddSurfaceImgToCourses < ActiveRecord::Migration[5.1]
  def change
    add_column :courses, :surface_img, :string
  end
end
