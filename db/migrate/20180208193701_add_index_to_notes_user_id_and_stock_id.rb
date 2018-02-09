class AddIndexToNotesUserIdAndStockId < ActiveRecord::Migration[5.1]
  def change
    add_index :notes, :user_id
    add_index :notes, :stock_id
  end
end
