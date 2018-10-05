class RemoveOpenidForUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :openid
  end
end
