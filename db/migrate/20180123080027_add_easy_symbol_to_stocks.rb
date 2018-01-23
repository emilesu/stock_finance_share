class AddEasySymbolToStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :easy_symbol, :string
    add_index :stocks, :easy_symbol, :unique => true
  end
end
