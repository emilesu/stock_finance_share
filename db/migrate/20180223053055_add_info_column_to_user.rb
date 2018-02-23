class AddInfoColumnToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :avatar, :string         #头像
    add_column :users, :username, :string       #用户名
    add_column :users, :motto, :string          #个人简介
  end
end
