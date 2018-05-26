class DeleteUsStockStaticDataColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :us_stocks, :static_data_10
    remove_column :us_stocks, :static_data_5
    remove_column :us_stocks, :static_data_2
    add_column :us_stocks, :static_data, :text
  end
end
