class AddTimeRangeTooUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :time_range, :string, :default => "all_years"
  end
end
