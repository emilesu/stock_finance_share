class AddUsSectorToSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :us_sector, :text
  end
end
