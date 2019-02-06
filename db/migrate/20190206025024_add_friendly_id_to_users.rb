class AddFriendlyIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :friendly_id, :string
    add_index :users, :friendly_id, :unique => true

    User.find_each do |i|
      i.update(:friendly_id => rand(36 ** 12).to_s(36))
    end
  end
end
