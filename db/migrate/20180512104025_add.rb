class Add < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :static_data_10, :text
    add_column :stocks, :static_data_5, :text
    add_column :stocks, :static_data_2, :text
  end
end
