class AddPyramidToSetting < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :a_pyramid, :text
    add_column :settings, :us_pyramid, :text
  end
end
