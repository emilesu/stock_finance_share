class AddDividendsTooStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :dividends, :text
  end
end
