class CreateUsTrades < ActiveRecord::Migration[5.1]
  def change
    create_table :us_trades do |t|
      t.integer :user_id, :index => true
      t.string :stock
      t.float :buy_price
      t.float :sell_price
      t.datetime :buy_time
      t.datetime :sell_time
      t.text :description
      t.string :status, :default => "公开"
      t.timestamps
    end
  end
end
