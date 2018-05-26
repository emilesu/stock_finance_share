class AddEasySymbolToUsStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :us_stocks, :easy_symbol, :string
    add_index :us_stocks, :easy_symbol, :unique => true
  end
end
