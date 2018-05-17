class AddCatalogToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :catalog, :string
  end
end
