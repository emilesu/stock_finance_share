class AddIndexTooTwitterStatus < ActiveRecord::Migration[5.1]
  def change
    add_index :twitters, :status
  end
end
