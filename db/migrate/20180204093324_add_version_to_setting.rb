class AddVersionToSetting < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :version, :integer
  end
end
