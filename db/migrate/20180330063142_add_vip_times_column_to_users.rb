class AddVipTimesColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :jion_time, :datetime
    add_column :users, :end_time, :datetime
    add_column :users, :nper, :integer
  end
end
