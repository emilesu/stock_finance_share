class AdjustSettingsVersion < ActiveRecord::Migration[5.1]
  def change
    rename_column :settings, :version, :version_1
    add_column :settings, :version_2, :integer
    add_column :settings, :version_3, :integer
    add_column :settings, :version_4, :integer
    add_column :settings, :version_5, :integer
    add_column :settings, :us_version_1, :integer
    add_column :settings, :us_version_2, :integer
    add_column :settings, :us_version_3, :integer
    add_column :settings, :us_version_4, :integer
    add_column :settings, :us_version_5, :integer
  end
end
