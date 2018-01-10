class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.string :name
      t.timestamps
    end

    add_index :stocks, :symbol, :unique => true
  end
end
