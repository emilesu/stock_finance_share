class ChangeCatalogTypeToFloat < ActiveRecord::Migration[5.1]
  def change
    change_column :posts, :catalog, :float
  end
end
