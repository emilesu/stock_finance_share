class ChangeTimeTypeToDatetimeStock < ActiveRecord::Migration[5.1]
  def change
    change_column :stocks, :time_to_market, :datetime
  end
end
