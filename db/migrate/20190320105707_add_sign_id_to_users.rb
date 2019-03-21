class AddSignIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :sign_id, :string
    add_index :users, :sign_id, :unique => true

    User.find_each do |i|
      i.update(:sign_id => rand(10 ** 6))
    end
  end
end
