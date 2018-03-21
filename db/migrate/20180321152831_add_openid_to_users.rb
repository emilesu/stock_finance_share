class AddOpenidToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :openid, :string
    add_index :users, :openid, :unique => true
  end
end
