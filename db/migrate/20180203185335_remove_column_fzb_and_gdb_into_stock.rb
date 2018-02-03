class RemoveColumnFzbAndGdbIntoStock < ActiveRecord::Migration[5.1]
  def change
    remove_column :stocks, :fzb
    remove_column :stocks, :gdb
  end
end
