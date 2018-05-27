class AdjustStockVersion < ActiveRecord::Migration[5.1]
  def change
    rename_column :stocks, :version, :version_1
    add_column :stocks, :version_2, :integer
    add_column :stocks, :version_3, :integer
    add_column :stocks, :version_4, :integer
    add_column :stocks, :version_5, :integer
    rename_column :us_stocks, :version, :us_version_1
    add_column :us_stocks, :us_version_2, :integer
    add_column :us_stocks, :us_version_3, :integer
    add_column :us_stocks, :us_version_4, :integer
    add_column :us_stocks, :us_version_5, :integer
  end
end
