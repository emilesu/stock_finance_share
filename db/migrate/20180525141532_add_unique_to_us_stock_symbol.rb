class AddUniqueToUsStockSymbol < ActiveRecord::Migration[5.1]
  def change
    change_column :us_stocks, :symbol, :string, :unique => true
    change_column :us_stocks, :cnname, :string, :unique => true
  end
end
