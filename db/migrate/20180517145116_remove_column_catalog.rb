class RemoveColumnCatalog < ActiveRecord::Migration[5.1]
  def change
    remove_column :posts, :catalog
  end
end
