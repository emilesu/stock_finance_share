class CreateUsStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :us_stocks do |t|
      t.string :symbol, :index => true, :unique => true
      t.string :cnname, :index => true
      t.string :market, :index => true
      t.string :pinyin
      t.text :cwzb
      t.text :lrb
      t.text :llb
      t.text :zcb
      t.string :industry
      t.string :main_business
      t.string :company_url
      t.integer :version
      t.datetime :time_to_market
      t.text :dividends
      t.text :static_data_10
      t.text :static_data_5
      t.text :static_data_2
      t.timestamps
    end
  end
end
