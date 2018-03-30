class RenameUsersJoinTime < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :jion_time, :join_time
  end
end
