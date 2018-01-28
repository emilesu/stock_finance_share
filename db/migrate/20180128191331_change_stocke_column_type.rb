class ChangeStockeColumnType < ActiveRecord::Migration[5.1]
  def change
    change_column :stocks, :lrb, :text
    change_column :stocks, :llb, :text
    change_column :stocks, :zcb, :text
    change_column :stocks, :fzb, :text
    change_column :stocks, :gdb, :text
  end
end
