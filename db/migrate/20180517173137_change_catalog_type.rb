class ChangeCatalogType < ActiveRecord::Migration[5.1]
  def change
    change_column :posts, :catalog, :string
  end
end
