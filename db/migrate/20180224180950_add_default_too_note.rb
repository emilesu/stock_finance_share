class AddDefaultTooNote < ActiveRecord::Migration[5.1]
  def change
    change_column :notes, :status, :string, :default => "公开"
    change_column :notes, :level, :string, :default => "近期关注"
  end
end
