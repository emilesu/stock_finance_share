class RemoveUsStockIdToNotes < ActiveRecord::Migration[5.1]
  def change
    remove_column :notes, :us_stock_id
  end
end
