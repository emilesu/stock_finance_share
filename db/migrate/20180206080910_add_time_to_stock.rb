class AddTimeToStock < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :time_to_market, :datetime
  end
end
