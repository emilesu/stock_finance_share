class ChangeSettingColumnType < ActiveRecord::Migration[5.1]
  def change
    change_column :settings, :industry, :text
  end
end
