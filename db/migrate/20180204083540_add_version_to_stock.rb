class AddVersionToStock < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :version, :integer
  end
end
