class Adjust < ActiveRecord::Migration[5.1]
  def change
    rename_column :settings, :industry, :a_industry
    add_column :settings, :us_industry, :text
  end
end
